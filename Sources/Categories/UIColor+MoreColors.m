//
//  UIColor+MoreColors.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 15.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "UIColor+MoreColors.h"

@implementation UIColor (MoreColors)

+ (UIColor *)colorFromInt:(int)rgbValue {
    return [UIColor colorWithRed:((float) ((rgbValue & 0xFF0000) >> 16)) / 255.0
                           green:((float) ((rgbValue & 0xFF00) >> 8)) / 255.0
                            blue:((float) (rgbValue & 0xFF)) / 255.0
                           alpha:1.0];
}

+ (UIColor *)colorForNormalStateTrigger {
    return [UIColor colorWithRed:156.f / 255.0
                           green:255.f / 255.0
                            blue:148.f / 255.0
                           alpha:1.0];
}

+ (UIColor *)colorForProblemTrigger {
    return [UIColor colorWithRed:254.f / 255.0
                           green:34.f / 255.0
                            blue:38.f / 255.0
                           alpha:1.0];
}

@end
