//
//  CommonActions.m
//  Zabbkit
//
//  Created by Andrey Kosykhin on 22.02.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "CommonActions.h"

@implementation CommonActions

+ (void)showErrorMessage:(NSString *)message
               withTitle:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:title
                  message:message
                 delegate:nil
        cancelButtonTitle:NSLocalizedString(@"Ok", nil)
        otherButtonTitles:nil];
    [alert show];
}

@end
