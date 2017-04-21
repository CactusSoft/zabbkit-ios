//
//  NavigationTableDataSource.h
//  Zabbkit
//
//  Created by Anna on 09.10.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZabbKitPaneType) {
    ZabbKitPaneTypeTopCell = 0,
    ZabbKitPaneTypeOverview,
    ZabbKitPaneTypeFavorites,
    ZabbKitPaneTypeNotifications,
    ZabbKitPaneTypeServerList,
    ZabbKitPaneTypeAbout,
    ZabbKitPaneTypeLogout,
    ZabbKitPaneTypeCount,
    ZabbKitPaneTypeNone = NSNotFound,
};

@interface NavigationTableDataSource : NSObject <UITableViewDataSource>

- (ZabbKitPaneType)paneViewControllerTypeForIndexPath:(NSIndexPath *)indexPath;

@end
