//
//  UITextField+Placeholder.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 29.01.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "UITextField+Placeholder.h"

@implementation UITextField (Placeholder)
- (void)drawPlaceholderInRect:(CGRect)rect
                        color:(UIColor *)color {
    [color setFill];
    [[self placeholder] drawInRect:rect withFont:[self font]];
}
@end
