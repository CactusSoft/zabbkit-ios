//
//  NavigationTableController.h
//  Zabbkit
//
//  Created by Alexey Dozortsev on 10.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NavigationTableDataSource.h"

@class RootViewController_iPhone;
@class MSNavigationPaneViewController;

@interface NavigationTableController_iPhone : BaseViewController

@property(nonatomic, strong) RootViewController_iPhone* owner;
@property(nonatomic, weak) MSNavigationPaneViewController* navigationPaneViewController;
@property(nonatomic, strong) NavigationTableDataSource *dataSource;

- (void)transitionToViewController:(ZabbKitPaneType)paneType;

@end
