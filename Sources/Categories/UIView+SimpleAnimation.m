//
//  UIView+SimpleAnimation.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 15.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "UIView+SimpleAnimation.h"

static const NSTimeInterval kDefaultAnimationDuration = .3;

@implementation UIView (SimpleAnimation)

- (void)setFrame:(CGRect)frame animatedWithDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setFrame:frame];
    } completion:nil];
}

- (void)setFrame:(CGRect)frame animated:(BOOL)animated {
    if (animated) {
        [self setFrame:frame animatedWithDuration:kDefaultAnimationDuration];
    } else {
        [self setFrame:frame];
    }
}

- (void)setAlpha:(CGFloat)alpha animatedWithDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setAlpha:alpha];
    } completion:nil];
}

@end
