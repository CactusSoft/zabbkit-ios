//
//  PushNotificationDelegate.h
//  Zabbkit
//
//  Created by Andrey Kosykhin on 19.06.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kZabbKitTokenReceivedNotification;

@interface PushNotificationDelegate : NSObject <UIApplicationDelegate>
- (void)registerPushNotification;
@end
