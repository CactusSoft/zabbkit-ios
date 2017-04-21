//
//  TriggersDataSourceManager.m
//  Zabbkit
//
//  Created by Alexey Dozortsev on 12.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "TriggersDataSourceManager.h"
#import "TriggerTableViewCell.h"
#import "ZabbixTrigger.h"
#import "TriggerEventsViewControlleriPhone.h"
#import "LoggedUser.h"
#import "ZabbixClientAPI.h"
#import "UIColor+MoreColors.h"

@interface TriggersDataSourceManager()  {
    __weak UIViewController* _ownerController;
    NSMutableArray* _items;
    BOOL _reloading;
}

- (NSMutableArray *)sortItems:(NSArray *)items;

@end


@implementation TriggersDataSourceManager

- (id)initWithOwnerController:(UIViewController*)owner
{
    self = [super init];
    if (self) {
        _ownerController = owner;
        _items = [NSMutableArray array];
    }
    return self;
}

- (void)refreshItems:(BOOL)isPullToRefresh type:(ItemType)itemType itemId:(NSString*)itemId success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    _reloading = YES;
    
    void (^successBlock)(NSArray *) = ^(NSArray *items) {
        _items = [self sortItems:items];
        _reloading = NO;
        success();
    };
    
    void (^failureBlock)(NSError *) = ^(NSError *error) {
        _reloading = NO;
        failure(error);
    };
    
    switch (itemType) {
        case ItemAll:
            [[LoggedUser sharedUser].clientAPI loadAllTrigersSuccess:successBlock failureBlock:failureBlock];
            break;
            
        case ItemGroup:
            [[LoggedUser sharedUser].clientAPI loadTriggersWithGroupId:itemId success:successBlock failureBlock:failureBlock];
            break;
            
        case ItemHost:
            [[LoggedUser sharedUser].clientAPI loadTriggersWithHostId:itemId success:successBlock failureBlock:failureBlock];
            break;
    }
}

- (void)clearData
{
    [_items removeAllObjects];
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
}

- (NSMutableArray *)sortItems:(NSArray *)items
{
    if (items.count == 0) {
        return nil;
    }
    
    NSMutableArray* problemTriggers = [NSMutableArray array];
    NSMutableArray* disasterTriggers = [NSMutableArray array];
    NSMutableArray* otherTriggers = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < [items count]; i++) {
        ZabbixTrigger* trigger = [items objectAtIndex:i];
        if (trigger.value == 1) {
            [problemTriggers addObject:trigger];
        } else if (trigger.value != 1 && trigger.priority == 5) {
            [disasterTriggers addObject:trigger];
        } else {
            [otherTriggers addObject:trigger];
        }
    }
    
    NSMutableArray* resultArray = [NSMutableArray array];
    [problemTriggers sortUsingComparator:^NSComparisonResult(ZabbixTrigger* tr1, ZabbixTrigger* tr2) {
        if (tr1.priority > tr2.priority) {
            return NSOrderedAscending;
        }
        if (tr1.priority < tr2.priority) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    [resultArray addObjectsFromArray:problemTriggers];
    [resultArray addObjectsFromArray:disasterTriggers];
    [resultArray addObjectsFromArray:otherTriggers];
    
    return resultArray;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_items.count == 0 && !_reloading) {
        return 1;
    }
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_items.count == 0) {
        static NSString* identifier = @"DefaultCell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.textLabel.textColor = [UIColor colorFromInt:0xb2b2b2];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
            cell.userInteractionEnabled = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor colorWithWhite:44.0f/255.0f alpha:1.0f];
            cell.textLabel.text = NSLocalizedString(@"No triggers found", nil);
        }
        return cell;
    } else {
        static NSString* identifier = @"OverViewCell";
        TriggerTableViewCell* cell = (TriggerTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[TriggerTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.userInteractionEnabled = YES;
        }
        [cell updateWithTrigger:[_items objectAtIndex:indexPath.row]];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZabbixTrigger* trigger = [_items objectAtIndex:indexPath.row];
    TriggerEventsViewControlleriPhone* triggerEventsVC = [[TriggerEventsViewControlleriPhone alloc] init];
    triggerEventsVC.trigger = trigger;
    [_ownerController.navigationController pushViewController:triggerEventsVC animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}

@end
