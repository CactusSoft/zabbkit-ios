//
//  OverviewDataSource.h
//  Zabbkit
//
//  Created by Alexey Dozortsev on 19.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupsViewControlleriPhone.h"

@protocol OverviewDataSource <NSObject>
@required
- (void)refreshItems:(BOOL)isPullToRefresh type:(ItemType)itemType itemId:(NSString*)itemId success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)clearData;
- (BOOL)isEmpty;
- (BOOL)isReloading;
- (void)updateLayout;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
@end