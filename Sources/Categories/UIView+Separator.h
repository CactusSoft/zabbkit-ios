//
//  UIView+Separator.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 04.02.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSInteger const kTopSeparatorTag = 2;
static NSInteger const kBottomSeparatorTag = 33;

@interface UIView (Separator)

+ (void)addBottomSeparatorToView:(UIView *)view withImage:(UIImage *)image;

+ (void)addTopSeparatorToView:(UIView *)view withImage:(UIImage *)image;

- (void)addBottomSeparatorLeft:(CGFloat)left right:(CGFloat)right height:(CGFloat)height color:(UIColor*)color;

- (void)addBottomSeparatorLeft:(CGFloat)left right:(CGFloat)right height:(CGFloat)height image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage;

@end
