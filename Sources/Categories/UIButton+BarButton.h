//
//  UIButton+BarButton.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 04.02.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BarButtonTypeBack,
    BarButtonTypeAction,
    BarButtonTypeGroups,
    BarButtonTypeAdd,
    BarButtonTypeDone,
    BarButtonTypeArrowRight,
    BarButtonTypeArrowLeft
} BarButtonType;

@interface UIButton (BarButton)
+ (UIBarButtonItem *)barButtonWithType:(BarButtonType)type
                                 title:(NSString *)title
                                target:(id)target
                                action:(SEL)action;

@end
