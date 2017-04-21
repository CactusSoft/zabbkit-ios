//
//  NavigationTableDataSource.m
//  Zabbkit
//
//  Created by Anna on 09.10.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "NavigationTableDataSource.h"
#import "TableHeaderViewCell.h"
#import "NavigationTableViewCell.h"
#import "LoggedUser.h"
#import "ZabbixServer.h"
#import "AppDelegate.h"

@implementation NavigationTableDataSource

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ZabbKitPaneTypeCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 44.0f + g_yUIShift;
    }
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString* const ZabbKitCellIdentifier = @"ZabbKitHeaderCell";
        
        TableHeaderViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ZabbKitCellIdentifier];
        if (cell == nil) {
            cell = [[TableHeaderViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZabbKitCellIdentifier];
        }
        
        cell.userNameLabel.text = [[LoggedUser sharedUser] nameUser];
        if ([[[LoggedUser sharedUser] currentServer] name].length > 0) {
            cell.serverNameLabel.text = [[[LoggedUser sharedUser] currentServer] name];
        } else if ([[[LoggedUser sharedUser] currentServer] url].length > 0) {
            cell.serverNameLabel.text = [[[LoggedUser sharedUser] currentServer] url];
        }
        return cell;
    } else {
        static NSString* const ZabbKitCellIdentifier = @"ZabbKitNavigationCell";
        NavigationTableViewCell* cell = (NavigationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:ZabbKitCellIdentifier];
        if (cell == nil) {
            cell = [[NavigationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZabbKitCellIdentifier];
        }
        [cell updateWithType:[self paneViewControllerTypeForIndexPath:indexPath]];
        return cell;
    }
}

- (ZabbKitPaneType)paneViewControllerTypeForIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.row < ZabbKitPaneTypeCount, @"Invalid Index Path");
    return indexPath.row;
}


@end
