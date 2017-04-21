//
//  HostGroupViewController.h
//  Shtirlits
//
//  Created by Artem Bartle on 12/12/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class OverviewViewControlleriPhone;

typedef enum {
    ItemAll = 0,
    ItemGroup,
    ItemHost
} ItemType;

@protocol GroupControllerOwner <NSObject>

@property(nonatomic, strong) NSString *selectedItemId;
@property(nonatomic, strong) NSString *selectedItemName;
@property(nonatomic, assign) ItemType currentType;

@end

@interface GroupsViewControlleriPhone : BaseViewController

@property(nonatomic, strong) NSArray *hostGroups;
@property(nonatomic, weak) id <GroupControllerOwner> owner;

@end
