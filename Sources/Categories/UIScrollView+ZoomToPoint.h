//
//  UIScrollView+ZoomToPoint.h
//  Shtirlits
//
//  Created by Artem Bartle on 1/5/13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (ZoomToPoint)

- (void)zoomToPoint:(CGPoint)zoomPoint
          withScale:(CGFloat)scale
           animated:(BOOL)animated;

@end
