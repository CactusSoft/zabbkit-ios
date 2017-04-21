//
//  UIButton+BarButton.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 04.02.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "UIButton+BarButton.h"

@implementation UIButton (BarButton)
+ (UIBarButtonItem *)barButtonWithType:(BarButtonType)type
                                 title:(NSString *)title
                                target:(id)target
                                action:(SEL)action {
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [newButton addTarget:target
                  action:action
        forControlEvents:UIControlEventTouchUpInside];
    switch (type) {
        case BarButtonTypeBack:
            [newButton setImage:[UIImage imageNamed:kImgServerListBackButtonNormal]
                       forState:UIControlStateNormal];
            [newButton setImage:[UIImage imageNamed:kImgServerListBackButtonTap]
                       forState:UIControlStateHighlighted];
            break;
        case BarButtonTypeAction:

            break;
        case BarButtonTypeGroups:
            [newButton setImage:[UIImage imageNamed:kImgGroupsButtonNormal]
                       forState:UIControlStateNormal];
            [newButton setImage:[UIImage imageNamed:kImgGroupsButtonTap]
                       forState:UIControlStateHighlighted];
            break;
        case BarButtonTypeAdd:
            [newButton setImage:[UIImage imageNamed:kImgButtonAddNormal]
                       forState:UIControlStateNormal];
            [newButton setImage:[UIImage imageNamed:kImgButtonAddTap]
                       forState:UIControlStateHighlighted];
            break;
        case BarButtonTypeDone:
            [newButton setImage:[UIImage imageNamed:kImgButtonDoneNormal]
                       forState:UIControlStateNormal];
            [newButton setImage:[UIImage imageNamed:kImgButtonDoneTap]
                       forState:UIControlStateHighlighted];
            break;
        case BarButtonTypeArrowLeft:
            [newButton setImage:[UIImage imageNamed:@"btn_left_normal"]
                       forState:UIControlStateNormal];
            [newButton setImage:[UIImage imageNamed:@"btn_left_tap"]
                       forState:UIControlStateHighlighted];
            break;
        case BarButtonTypeArrowRight:
            [newButton setImage:[UIImage imageNamed:@"btn_right_normal"]
                       forState:UIControlStateNormal];
            [newButton setImage:[UIImage imageNamed:@"btn_right_tap"]
                       forState:UIControlStateHighlighted];
            break;
    }
    [newButton sizeToFit];
    UIBarButtonItem *newBarButton = [[UIBarButtonItem alloc] initWithCustomView:newButton];
    return newBarButton;
}

@end
