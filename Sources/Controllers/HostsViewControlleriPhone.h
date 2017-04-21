//
//  HostsViewControlleriPhone.h
//  Shtirlits
//
//  Created by Artem Bartle on 1/10/13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "GroupsViewControlleriPhone.h"

@class ZabbixHostGroup;

@interface HostsViewControlleriPhone : BaseViewController

@property(nonatomic, strong) ZabbixHostGroup* group;
@property(nonatomic, strong) NSArray* hosts;
@property(nonatomic, weak) id <GroupControllerOwner> owner;

@end

