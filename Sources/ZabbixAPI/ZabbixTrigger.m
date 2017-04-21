//
//  ZabbixTrigger.m
//  Shtirlits
//
//  Created by Artem Bartle on 12/7/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "ZabbixTrigger.h"

@implementation ZabbixTrigger

+ (NSString *)triggerPriorityString:(ZabbixTriggerPriority)priority {
    switch (priority) {
        case ZabbixTriggerPriorityNotClassified:
            return @"Not Classified";
            break;
        case ZabbixTriggerPriorityInformation:
            return @"Information";
            break;
        case ZabbixTriggerPriorityWarning:
            return @"Warning";
            break;
        case ZabbixTriggerPriorityAverage:
            return @"Average";
            break;
        case ZabbixTriggerPriorityHigh:
            return @"High";
            break;
        case ZabbixTriggerPriorityDisaster:
            return @"Disaster";
            break;
        default:
            break;
    }
}

+ (UIColor *)triggerPriorityColor:(ZabbixTriggerPriority)priority {
    switch (priority) {
        case ZabbixTriggerPriorityNotClassified:
            return [UIColor colorWithRed:211 / 255.0 green:211 / 255.0 blue:211 / 255.0 alpha:1.0];
            break;
        case ZabbixTriggerPriorityInformation:
            return [UIColor colorWithRed:205 / 255.0 green:244 / 255.0 blue:255 / 255.0 alpha:1.0];
            break;
        case ZabbixTriggerPriorityWarning:
            return [UIColor colorWithRed:255 / 255.0 green:248 / 255.0 blue:141 / 255.0 alpha:1.0];
            break;
        case ZabbixTriggerPriorityAverage:
            return [UIColor colorWithRed:255 / 255.0 green:168 / 255.0 blue:114 / 255.0 alpha:1.0];
            break;
        case ZabbixTriggerPriorityHigh:
            return [UIColor colorWithRed:254 / 255.0 green:133 / 255.0 blue:134 / 255.0 alpha:1.0];
            break;
        case ZabbixTriggerPriorityDisaster:
            return [UIColor colorWithRed:254 / 255.0 green:34 / 255.0 blue:38 / 255.0 alpha:1.0];
            break;
        default:
            break;
    }
}

@end
