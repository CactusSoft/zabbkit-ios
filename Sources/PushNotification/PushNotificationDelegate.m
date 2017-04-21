//
//  PushNotificationDelegate.m
//  Zabbkit
//
//  Created by Andrey Kosykhin on 19.06.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "PushNotificationDelegate.h"
#import "LoggedUser.h"
#import "ZabbKitApplicationSettings.h"
#import "AFJSONRequestOperation.h"
#import "ZabbixRequestHelper.h"

static NSString *const kShowChangesNotificationKey = @"url";
static NSString *const kDownloadNotificationKey = @"install_url";
static NSString *const kInfoNotificationKey = @"aps";
static NSString *const kAlertNotificationKey = @"alert";

static NSString *const kAlertTitle = @"Alert";
static NSString *const kAlertMessage = @"This application has a new version";
static NSString *const kAlertMessageTrigger = @"New trigger %@";

static NSString *const kShowChangesTitle = @"What's new";
static NSString *const kDownloadNewVersionTitle = @"Download";
static NSString *const kCancelTitle = @"Cancel";

NSString *const kZabbKitTokenReceivedNotification = @"ZabbKitTokenReceivedNotification";

@interface PushNotificationDelegate () <UIAlertViewDelegate> {
    AFJSONRequestOperation *requestOperation;
    BOOL tokenIsLoading;
    NSMutableArray *receivedUrls;
}

- (void)registerPushNotification;

- (void)registerZabbixPushNotification:(NSString *)apnsToken;

- (void)renewZabbixDeviceId:(NSString *)zabbkitDeviceId oldApnsToken:(NSString *)oldToken newApnsToken:(NSString *)newToken;

- (void)receiveDeviceToken:(NSData *)deviceToken;

- (void)receivePushNotification:(NSDictionary *)notification;

- (void)clearAllNotifications;

@end

@implementation PushNotificationDelegate

#pragma mark - UIApplication Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    id notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        [self clearAllNotifications];
        [self receivePushNotification:notification];
    } else {
        [self registerPushNotification];
    }
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self receiveDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self clearAllNotifications];
    [self receivePushNotification:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    tokenIsLoading = NO;
    NSLog(@"Fail to register remote notifications, error = %@", error);
}

#pragma mark - Push Notification logic

- (void)registerPushNotification {
    if (!tokenIsLoading) {
        tokenIsLoading = YES;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void)registerZabbixPushNotification:(NSString *)apnsToken {
    [requestOperation cancel];
    requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[ZabbixRequestHelper pushNotificationRegistrationWithToken:apnsToken] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary *jsonDict = (NSDictionary *) JSON;
        NSString *token = [jsonDict objectForKey:@"Id"];
        [ZabbKitApplicationSettings sharedApplicationSettings].zabkitToken = token;
        [ZabbKitApplicationSettings sharedApplicationSettings].apnsToken = apnsToken;
        [LoggedUser sharedUser].idPushNotification = token;
        [[NSNotificationCenter defaultCenter] postNotificationName:kZabbKitTokenReceivedNotification object:nil];
        tokenIsLoading = NO;
    }                                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        tokenIsLoading = NO;
    }];
    [requestOperation start];
}

- (void)renewZabbixDeviceId:(NSString *)zabbkitDeviceId oldApnsToken:(NSString *)oldToken newApnsToken:(NSString *)newToken {
    [requestOperation cancel];
    NSURLRequest *request = [ZabbixRequestHelper pushNotificationRenewToken:newToken oldToken:oldToken idPush:zabbkitDeviceId];
    requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary *jsonDict = (NSDictionary *) JSON;
        NSString *token = [jsonDict objectForKey:@"Id"];
        [ZabbKitApplicationSettings sharedApplicationSettings].zabkitToken = token;
        [ZabbKitApplicationSettings sharedApplicationSettings].apnsToken = newToken;
        [LoggedUser sharedUser].idPushNotification = token;
        [[NSNotificationCenter defaultCenter] postNotificationName:kZabbKitTokenReceivedNotification object:nil];
        tokenIsLoading = NO;
    }                                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        tokenIsLoading = NO;
    }];
    [requestOperation start];
}

- (void)receiveDeviceToken:(NSData *)deviceToken {
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];

    if ([ZabbKitApplicationSettings sharedApplicationSettings].zabkitToken.length == 0) {
        [self registerZabbixPushNotification:newToken];
    } else if (![[ZabbKitApplicationSettings sharedApplicationSettings].apnsToken isEqualToString:newToken]) {
        NSString *zabbkitDeviceId = [ZabbKitApplicationSettings sharedApplicationSettings].zabkitToken;
        NSString *oldToken = [ZabbKitApplicationSettings sharedApplicationSettings].apnsToken;
        [self renewZabbixDeviceId:zabbkitDeviceId oldApnsToken:oldToken newApnsToken:newToken];
    } else {
        tokenIsLoading = NO;
    }
}

- (void)receivePushNotification:(NSDictionary *)notification {
    if (receivedUrls == nil) {
        receivedUrls = [NSMutableArray array];
    }
    [receivedUrls removeAllObjects];
    
    id notificationInfo = [notification objectForKey:kInfoNotificationKey];

    if ([notificationInfo isKindOfClass:[NSDictionary class]]) {
        
        NSString * alertText = [(NSDictionary*)notificationInfo objectForKey:kAlertNotificationKey];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAlertTitle message:alertText delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        
        id showChangesUrl = [notification objectForKey:kShowChangesNotificationKey];
        if (showChangesUrl) {
            [alertView addButtonWithTitle:kShowChangesTitle];
            [receivedUrls addObject:showChangesUrl];
        }
        
        id downloadUrl = [notification objectForKey:kDownloadNotificationKey];
        if (downloadUrl) {
            [alertView addButtonWithTitle:kDownloadNewVersionTitle];
            [receivedUrls addObject:downloadUrl];
        }
        
        alertView.cancelButtonIndex = [alertView addButtonWithTitle:kCancelTitle];
        [alertView show];
    }

//    id objectTrigger = [notification objectForKey:@"tid"];
//    NSString *message = [NSString stringWithFormat:kAlertMessageTrigger, objectTrigger];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAlertTitleTrigger message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
}

- (void)clearAllNotifications {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString *url = [receivedUrls objectAtIndex:buttonIndex];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    receivedUrls = nil;
}

@end
