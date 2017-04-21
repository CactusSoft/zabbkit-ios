//
//  AppDelegate.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 13.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushNotificationDelegate.h"

extern float g_yUIShift;

@interface AppDelegate : PushNotificationDelegate <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate *) sharedAppDelegate;

@end
