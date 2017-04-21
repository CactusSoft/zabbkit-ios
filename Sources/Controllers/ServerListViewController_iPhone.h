//
//  ServerListViewControlleriPhone.h
//  Shtirlits
//
//  Created by bartle on 12/27/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef void(^ServerListVCServerSelected)();

@class RootViewController_iPhone;

@interface ServerListViewController_iPhone : BaseViewController

@property(nonatomic, weak) RootViewController_iPhone* owner;
@property(nonatomic, copy) ServerListVCServerSelected completion;

@end
