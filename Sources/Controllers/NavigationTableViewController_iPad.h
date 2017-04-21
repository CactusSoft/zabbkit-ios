//
//  NavigationTableViewController_iPad.h
//  Zabbkit
//
//  Created by Anna on 09.10.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NavigationTableDataSource.h"
#import "NavigationDetailsViewController_iPad.h"
#import "RootViewController_iPhone.h"

@interface NavigationTableViewController_iPad : BaseViewController <UISplitViewControllerDelegate>

@property(nonatomic, strong) RootViewController_iPhone* owner;
@property(nonatomic, strong) NavigationTableDataSource *dataSource;
@property (nonatomic, weak) UISplitViewController *splitViewController;
@property (nonatomic, weak) NavigationDetailsViewController_iPad  *detailViewController;

@end
