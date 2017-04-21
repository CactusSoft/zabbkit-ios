//
//  EventTableViewCell.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 04.02.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZabbixEvent;
@class ZabbixTrigger;

@interface EventTableViewCell : UITableViewCell

//if description not nil then it will be used instead of event.description
+ (CGFloat)heightForEvent:(ZabbixEvent*)event trigger:(ZabbixTrigger*)trigger withWidth:(CGFloat)width;

- (void)updateWithTrigger:(ZabbixTrigger*)trigger event:(ZabbixEvent*)event;

@end
