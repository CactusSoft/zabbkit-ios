//
//  UITextField+Placeholder.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 29.01.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Placeholder)
- (void)drawPlaceholderInRect:(CGRect)rect
                        color:(UIColor *)color;
@end
