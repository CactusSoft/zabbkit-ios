//
//  RootViewControllerIPhone.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 13.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class LoginView;

@interface RootViewController_iPhone : BaseViewController

@property(nonatomic, strong) LoginView *loginView;
@property(nonatomic, assign) BOOL isCanAnimate;

- (void)presentPaneViewController;
- (void)dismissPaneViewController;

@end
