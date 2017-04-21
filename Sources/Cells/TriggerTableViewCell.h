//
//  TriggerTableViewCell.h
//  ZabbKit
//
//  Created by Alexey Dozotysev on 07.12.12.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZabbixTrigger;

@interface TriggerTableViewCell : UITableViewCell

- (void) updateWithTrigger:(ZabbixTrigger*)trigger;

@end
