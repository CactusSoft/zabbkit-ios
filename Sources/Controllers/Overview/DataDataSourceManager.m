//
//  DataDataSourceManager.m
//  Zabbkit
//
//  Created by Alexey Dozortsev on 12.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "DataDataSourceManager.h"
#import "LoggedUser.h"
#import "ZabbixClientAPI.h"
#import "DataTableViewCell.h"
#import "GraphViewControlleriPhone.h"
#import "ZabbixItem.h"
#import "ZabbixHost.h"

@interface DataDataSourceManager() {
    __weak UIViewController* _ownerController;
    NSMutableArray* _items;
    BOOL _reloading;
    ItemType _itemType;
}

@end


@implementation DataDataSourceManager

- (id)initWithOwnerController:(UIViewController*)owner
{
    self = [super init];
    if (self) {
        _itemType = ItemAll;
        _ownerController = owner;
        _items = [NSMutableArray array];
        _reloading = NO;
    }
    return self;
}

- (void)refreshItems:(BOOL)isPullToRefresh type:(ItemType)itemType itemId:(NSString*)itemId success:(void (^)())success failure:(void (^)(NSError *error))failure;
{
    _reloading = YES;
    _itemType = itemType;
    void (^successBlock)(NSArray *) = ^(NSArray *items) {
        [_items removeAllObjects];
        [_items addObjectsFromArray:[self sortItems:items]];
        _reloading = NO;
        success();
    };
    
    void (^failureBlock)(NSError *) = ^(NSError *error) {
        _reloading = NO;
        failure(error);
    };
    
    switch (_itemType) {
        case ItemAll:
            [[LoggedUser sharedUser].clientAPI loadAllItemsWithSuccess:successBlock failureBlock:failureBlock];
            break;
            
        case ItemGroup:
            [[LoggedUser sharedUser].clientAPI loadItemsWithGroupId:itemId success:successBlock failureBlock:failureBlock];
            break;
            
        case ItemHost:
            [[LoggedUser sharedUser].clientAPI loadItemsWithHostId:itemId success:successBlock failureBlock:failureBlock];
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

- (NSArray *)sortItems:(NSArray *)items
{
    if (items.count == 0) {
        return items;
    }
    NSArray* sortedItems = [items sortedArrayUsingComparator:^NSComparisonResult(ZabbixItem* obj1, ZabbixItem* obj2) {
        NSComparisonResult result = [obj1.host.hostName compare:obj2.host.hostName options:NSCaseInsensitiveSearch];
        if (result == NSOrderedSame) {
            result = [obj1.itemName compare:obj2.itemName options:NSCaseInsensitiveSearch];
        }
        return result;
    }];
    return sortedItems;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"DataTableViewCell";
    DataTableViewCell* cell = (DataTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[DataTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    [cell updateWithItem:[_items objectAtIndex:indexPath.row]];
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
    ZabbixItem* item = [_items objectAtIndex:indexPath.row];
    GraphViewControlleriPhone* graphVC = [[GraphViewControlleriPhone alloc] init];
    graphVC.graph = item.graph;
    [_ownerController presentViewController:graphVC animated:YES completion:nil];
}

@end
