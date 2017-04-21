//
//  UIView+Separator.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 04.02.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "UIView+Separator.h"

@implementation UIView (Separator)

+ (void)addTopSeparatorToView:(UIView *)view
                    withImage:(UIImage *)image {
    CGRect separatorFrame = CGRectMake(0,
            0,
            view.bounds.size.width,
            image.size.height);
    UIImageView *separator = [[UIImageView alloc] initWithFrame:separatorFrame];
    separator.tag = kTopSeparatorTag;
    [separator setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin |
            UIViewAutoresizingFlexibleWidth)];
    [separator setBackgroundColor:[UIColor clearColor]];
    separator.image = image;
    [view addSubview:separator];
}

+ (void)addBottomSeparatorToView:(UIView *)view
                       withImage:(UIImage *)image {
    CGRect separatorFrame =
            CGRectMake(0,
                    view.bounds.size.height - image.size.height,
                    view.bounds.size.width,
                    image.size.height);
    UIImageView *separator = [[UIImageView alloc] initWithFrame:separatorFrame];
    separator.tag = kBottomSeparatorTag;
    [separator setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleWidth)];
    [separator setBackgroundColor:[UIColor clearColor]];
    separator.image = image;
    [view addSubview:separator];
}

- (void)addBottomSeparatorLeft:(CGFloat)left right:(CGFloat)right height:(CGFloat)height color:(UIColor*)color
{
    CGRect frame = CGRectMake(left, self.bounds.size.height - height, self.bounds.size.width - left - right, height);
    UIView* separator = [[UIView alloc] initWithFrame:frame];
    separator.tag = kBottomSeparatorTag;
    [separator setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth)];
    [separator setBackgroundColor:color];
    [self addSubview:separator];
}

- (void)addBottomSeparatorLeft:(CGFloat)left right:(CGFloat)right height:(CGFloat)height image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage
{
    CGRect frame = CGRectMake(left, self.bounds.size.height - height, self.bounds.size.width - left - right, height);
    UIImageView* separator = [[UIImageView alloc] initWithFrame:frame];
    separator.tag = kBottomSeparatorTag;
    [separator setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth)];
    [separator setImage:image];
    [separator setHighlightedImage:highlightedImage];
    [self addSubview:separator];
}

@end
