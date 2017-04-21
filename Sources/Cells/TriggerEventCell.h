//
//  TriggerEventCell.h
//  ZabbKit
//
//  Created by Alexey Dozortsev on 18.09.13.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZabbixEvent;
@class ZabbixTrigger;

@interface TriggerEventCell : UITableViewCell

- (void)updateWithTrigger:(ZabbixTrigger*)trigger event:(ZabbixEvent*)event;

@end
