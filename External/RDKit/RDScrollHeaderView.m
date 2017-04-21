//
//  RDScrollHeaderView.m
//  RDKit
//
//  Created by Alexey Dozortsev on 11.09.13.
//
//

#import "RDScrollHeaderView.h"

@interface RDScrollHeaderView () {
    CGPoint _prevOffset;
    
    BOOL isDecelerating;
    BOOL isDeceleratingUp;
}

@end


@implementation RDScrollHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _prevOffset = CGPointMake(0.0f, 0.0f);
        isDecelerating = NO;
        isDeceleratingUp = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.superview bringSubviewToFront:self];
    CGRect frame = self.frame;
    
    isDeceleratingUp = !scrollView.tracking && scrollView.isDecelerating && _prevOffset.y > scrollView.contentOffset.y;
    
    if (isDeceleratingUp) {
        if (frame.origin.y + frame.size.height < scrollView.contentOffset.y) {
            frame.origin.y = scrollView.contentOffset.y - frame.size.height + 0.5f;
        }
    } else if (frame.origin.y + frame.size.height < scrollView.contentOffset.y){
        frame.origin.y = -self.frame.size.height;
    }
    
    if (frame.origin.y > scrollView.contentOffset.y || scrollView.contentOffset.y < -self.frame.size.height) {//align to top
        frame.origin.y = scrollView.contentOffset.y;
    }
    
    self.frame = frame;
    _prevOffset = scrollView.contentOffset;
}

@end
