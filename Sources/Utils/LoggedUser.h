//
//  LoggedUser.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 23.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Keychain.h"
#import "ZabbKitApplicationSettings.h"
#import "AFHTTPClient.h"

// Protected login
extern NSString *const kProtectedLoginKeyString;
extern NSString *const kProtectedPasswordKeyString;

@protocol LoggedUserDelegate;
@class ZabbixClientAPI;
@class ZabbixServer;

@interface LoggedUser : NSObject
@property(nonatomic, unsafe_unretained) id <LoggedUserDelegate> delegate;
@property(nonatomic, strong) NSString *nameUser;
@property(nonatomic, strong) NSString *urlString;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong) NSString *deviceToken;
@property(nonatomic, strong) NSString *idPushNotification;
@property(nonatomic, strong) ZabbixServer *currentServer;
@property(nonatomic, strong) ZabbixClientAPI *clientAPI;
@property(nonatomic, strong) AFHTTPClient *client;
@property(nonatomic, assign) BOOL userIsLoginIn;

+ (LoggedUser *)sharedUser;

- (void)removeCredentials;

- (void)logout;

- (void)cancelLoginRequest;

- (void)startLogin:(NSString *)userName urlString:(NSString *)urlString userPassword:(NSString *)userPassword;

- (void)loginWithDefaultValues;

- (void)makeTrustedServer;

@end

@protocol LoggedUserDelegate <NSObject>
@optional
- (void)didStartRequest;

- (void)didSuccessfullyLogin;

- (void)didSuccessfullyLogout;

- (void)didFailLoginWithError:(NSError *)error;

- (void)didFailLogoutWithError:(NSError *)error;
@end
