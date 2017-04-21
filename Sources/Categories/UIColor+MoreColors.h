//
//  UIColor+MoreColors.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 15.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (MoreColors)

+ (UIColor *)colorFromInt:(int)rgbValue;

+ (UIColor *)colorForNormalStateTrigger;

+ (UIColor *)colorForProblemTrigger;

@end
