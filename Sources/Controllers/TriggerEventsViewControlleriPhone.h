//
//  TriggerEventsViewControlleriPhone.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 12.12.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class ZabbixTrigger;

@interface TriggerEventsViewControlleriPhone : BaseViewController

@property(nonatomic, strong) ZabbixTrigger* trigger;

@end

