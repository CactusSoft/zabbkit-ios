//
//  OldSchoolNavigationController.m
//  Zabbkit
//
//  Created by Dmitry Predko on 13.6.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "OldSchoolNavigationController.h"

@implementation OldSchoolNavigationController

- (NSUInteger)supportedInterfaceOrientations {
    if ([self.topViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [self.topViewController supportedInterfaceOrientations];
    }
    else {
        return [super supportedInterfaceOrientations];
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
