//
//  UIView+SimpleAnimation.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 15.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SimpleAnimation)
- (void)setFrame:(CGRect)frame animatedWithDuration:(NSTimeInterval)duration;

- (void)setFrame:(CGRect)frame animated:(BOOL)animated;

- (void)setAlpha:(CGFloat)alpha animatedWithDuration:(NSTimeInterval)duration;
@end
