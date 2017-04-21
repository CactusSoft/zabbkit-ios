//
//  EventsDataSourceManager.m
//  Zabbkit
//
//  Created by Alexey Dozortsev on 12.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "EventsDataSourceManager.h"
#import "EventTableViewCell.h"
#import "LoggedUser.h"
#import "ZabbixClientAPI.h"
#import "ZabbixEvent.h"
#import "UIColor+MoreColors.h"
#import "ZabbixTrigger.h"

@interface EventsDataSourceManager() {
    __weak UIViewController* _ownerController;
    __weak UITableView* _tableView;
    NSMutableArray* _items;
    NSMutableDictionary* _triggers;
    NSMutableDictionary* _cellsHeightsCache;
    BOOL _reloading;
}

- (NSMutableArray *)sortItems:(NSArray *)items;

@end


@implementation EventsDataSourceManager

- (id)initWithOwnerController:(UIViewController*)owner tableView:(UITableView*)tableView
{
    self = [super init];
    if (self) {
        _ownerController = owner;
        _tableView = tableView;
        _items = [NSMutableArray array];
        _triggers = [[NSMutableDictionary alloc] init];
        _cellsHeightsCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)refreshItems:(BOOL)isPullToRefresh type:(ItemType)itemType itemId:(NSString*)itemId success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    _reloading = YES;
    void (^successBlock)(NSArray *) = ^(NSArray *events) {
        
        NSMutableSet* triggersSet = [NSMutableSet set];
        [events enumerateObjectsUsingBlock:^(ZabbixEvent* event, NSUInteger idx, BOOL *stop) {
            [triggersSet addObject:event.objectid];
        }];
        
        [[LoggedUser sharedUser].clientAPI loadTriggersWithIds:triggersSet success:^(NSArray *triggers) {
            [_triggers removeAllObjects];
            [triggers enumerateObjectsUsingBlock:^(ZabbixTrigger* trigger, NSUInteger idx, BOOL *stop) {
                [_triggers setObject:trigger forKey:trigger.triggerid];
            }];
            
            [_items removeAllObjects];
            [_items addObjectsFromArray:[self sortItems:events]];
            _reloading = NO;
            success();
        } failureBlock:^(NSError *error) {
            _reloading = NO;
            failure(error);
        }];
        
    };
    
    void (^failureBlock)(NSError *) = ^(NSError *error) {
        _reloading = NO;
        failure(error);
    };
    
    switch (itemType) {
        case ItemAll:
            [[LoggedUser sharedUser].clientAPI loadAllEventsSuccess:successBlock failureBlock:failureBlock];
            break;
            
        case ItemGroup:
            [[LoggedUser sharedUser].clientAPI loadEventsWithGroupId:itemId success:successBlock failureBlock:failureBlock];
            break;
            
        case ItemHost:
            [[LoggedUser sharedUser].clientAPI loadEventsWithHostId:itemId success:successBlock failureBlock:failureBlock];
            break;
    }
}

- (void)clearData
{
    [_items removeAllObjects];
    [_triggers removeAllObjects];
    [_cellsHeightsCache removeAllObjects];
}

- (BOOL)isEmpty
{
    return _items.count == 0;
}

- (BOOL)isReloading
{
    return _reloading;
}

- (void)updateLayout
{
    [_cellsHeightsCache removeAllObjects];
    [_tableView reloadData];
}

- (NSArray *)sortItems:(NSArray *)items
{
    NSMutableDictionary* eventsDictionary = [NSMutableDictionary dictionary];
    for (ZabbixEvent* event in items) {
        NSMutableArray* eventsForTrigger = [eventsDictionary objectForKey:event.objectid];
        if (eventsForTrigger == nil) {
            eventsForTrigger = [NSMutableArray array];
            [eventsDictionary setObject:eventsForTrigger forKey:event.objectid];
        }
        [eventsForTrigger addObject:event];
    }
    
    for (NSString* key in [eventsDictionary allKeys]) {
        NSMutableArray *events = [eventsDictionary objectForKey:key];
        NSArray* sortedByDateEvents = [events sortedArrayUsingComparator:^NSComparisonResult(ZabbixEvent* obj1, ZabbixEvent* obj2) {
            if (obj1.clock < obj2.clock) {
                return NSOrderedAscending;
            }
            if (obj1.clock > obj2.clock) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        
        for (int i = 0; i < [sortedByDateEvents count]-1; i++) {
            ZabbixEvent* event = [sortedByDateEvents objectAtIndex:i];
            ZabbixEvent* nextEvent = [sortedByDateEvents objectAtIndex:i + 1];
            event.duration = nextEvent.clock - event.clock;
        }
        ZabbixEvent* latestEvent = [sortedByDateEvents lastObject];
        NSDate* latestEventDate = [NSDate dateWithTimeIntervalSince1970:latestEvent.clock];
        [latestEvent setDuration:fabs([latestEventDate timeIntervalSinceNow])];
    }
    
    NSArray* sortedByDateItems = [items sortedArrayUsingComparator:^NSComparisonResult(ZabbixEvent* obj1, ZabbixEvent* obj2) {
        if (obj1.clock > obj2.clock) {
            return NSOrderedAscending;
        }
        if (obj1.clock < obj2.clock) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    return sortedByDateItems;
}

- (void)reloadDataByTime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadDataByTime) object:nil];
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _items.count) {
        return 44.0f;
    }
    
    ZabbixEvent* event = (ZabbixEvent *)[_items objectAtIndex:indexPath.row];
    
    NSNumber* heightNumber = [_cellsHeightsCache objectForKey:event.objectid];
    if (heightNumber != nil) {
        return [heightNumber floatValue];
    }
    
    ZabbixTrigger* trigger = [_triggers objectForKey:event.objectid];
    
    CGFloat height = [EventTableViewCell heightForEvent:event trigger:trigger withWidth:tableView.bounds.size.width];
    height = roundf(height);
    
    //add to cache
    [_cellsHeightsCache setObject:[NSNumber numberWithFloat:height] forKey:event.objectid];
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTableViewCell* cell;
    if (indexPath.row < _items.count) {
        static NSString* identifier = @"EventsCell";
        cell = (EventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        
        ZabbixEvent* event = [_items objectAtIndex:indexPath.row];
        ZabbixTrigger* trigger = [_triggers objectForKey:event.objectid];
        [cell updateWithTrigger:trigger event:event];
        
    } else {
        
        static NSString* identifier = @"DefualtEventsCell";
        cell = (EventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.textLabel.text = NSLocalizedString(@"There are no events for last month", nil);
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        }
        
        if (_items.count == 0 && !_reloading) {
            cell.contentView.hidden = NO;
        } else {
            cell.contentView.hidden = YES;
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}

@end
