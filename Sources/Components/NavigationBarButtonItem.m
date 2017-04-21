//
//  NavigationBarButtonItem.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 18.02.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "NavigationBarButtonItem.h"

@interface NavigationBarButtonItem () {
}

@end

@implementation NavigationBarButtonItem
@synthesize actionButton = actionButton_;

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    self = [super initWithTitle:title style:style target:target action:action];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action {
    self = [super initWithBarButtonSystemItem:systemItem target:target action:action];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCustomView:(UIView *)customView {
    self = [super initWithCustomView:customView];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    self = [super initWithImage:image style:style target:target action:action];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image landscapeImagePhone:(UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    self = [super initWithImage:image landscapeImagePhone:landscapeImagePhone style:style target:target action:action];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    actionButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionButton_ sizeToFit];
    self.customView = actionButton_;
}

- (void)setTypeButton:(NavigationBarButtonItemType)typeButton {
    switch (typeButton) {
        case NavigationBarButtonItemTypeBack:
            [actionButton_ setImage:[UIImage imageNamed:kImgServerListBackButtonNormal]
                           forState:UIControlStateNormal];
            [actionButton_ setImage:[UIImage imageNamed:kImgServerListBackButtonTap]
                           forState:UIControlStateHighlighted];
            break;
        case NavigationBarButtonItemTypeLeft:
            [actionButton_ setImage:[UIImage imageNamed:@"btn_left_normal"]
                           forState:UIControlStateNormal];
            [actionButton_ setImage:[UIImage imageNamed:@"btn_left_tap"]
                           forState:UIControlStateHighlighted];
            break;
        case NavigationBarButtonItemTypeRight:
            [actionButton_ setImage:[UIImage imageNamed:@"btn_right_normal"]
                           forState:UIControlStateNormal];
            [actionButton_ setImage:[UIImage imageNamed:@"btn_right_tap"]
                           forState:UIControlStateHighlighted];
            break;
    }
    [actionButton_ sizeToFit];
}

@end
