//
//  LoggedUser.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 23.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "LoggedUser.h"

#import "AFHTTPRequestOperation.h"
#import "NSString+AdditionsMethods.h"
#import "NSURL+URLfromString.h"
#import "ZabbixClientAPI.h"
#import "ZabbixUser.h"
#import "ZabbixRequestHelper.h"
#import "ZabbixServer.h"
#import "Flurry.h"

// Protected login
NSString *const kProtectedLoginKeyString = @"ShtirlitsProtectedLogin";
NSString *const kProtectedPasswordKeyString = @"ShtirlitsProtectedPassword";
NSString *const kProtectedURLKeyString = @"ShtirlitsProtectedURL";

@interface LoggedUser () {
    ZabbixServer *_currentServer;
}

@end

@implementation LoggedUser

#pragma mark - Singleton Stuff

+ (LoggedUser *)sharedUser {
    static LoggedUser *sharedUser = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedUser = [[super alloc] init];
    });
    return sharedUser;
}

- (id)init {
    self = [super init];
    if (self) {
        _clientAPI = [ZabbixClientAPI new];
        [self initUserWithDefaults];
    }
    return self;
}

- (void)initUserWithDefaults {
    _userIsLoginIn = NO;
    BOOL loginAutomatically = [ZabbKitApplicationSettings sharedApplicationSettings].loginAutomatically;
    _nameUser = [Keychain getStringForKey:kProtectedLoginKeyString];
    _urlString = [Keychain getStringForKey:kProtectedURLKeyString];
    _password = nil;
    if (loginAutomatically) {
        _password = [Keychain getStringForKey:kProtectedPasswordKeyString];
    } else {
        [Keychain deleteStringForKey:kProtectedPasswordKeyString];
    }
    
    [self createNewClientWithURL:_urlString];
}

- (void)createNewClientWithURL:(NSString *)newUrl {
    NSURL *url = [NSURL URLWithString:newUrl];
    if (url != nil) {
        _urlString = newUrl;
        _client = [[AFHTTPClient alloc] initWithBaseURL:url];
        [_client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        ZabbixRequestHelper *requestHelper = [[ZabbixRequestHelper alloc] initWithUrlString:newUrl];
        self.clientAPI.requestHelper = requestHelper;
    }
}

#pragma mark - Getters and Setters

- (ZabbixServer *)currentServer
{
    ZabbixServer *zabbixServer = [self serverFromListWithUrl:_urlString];
    if (zabbixServer) {
        _currentServer = zabbixServer;
    } else if (_currentServer == nil || ![_currentServer.url isEqualToString:_urlString]) {
        _currentServer = [[ZabbixServer alloc] initWithUrl:_urlString];
    }
    return _currentServer;
}

- (void)setCurrentServer:(ZabbixServer *)currentServer
{
    if (currentServer != _currentServer) {
        _currentServer = currentServer;
        [self createNewClientWithURL:_currentServer.url];
    }
}

#pragma mark - Login Methods

- (void)loginWithDefaultValues {
    [self startLogin:_nameUser urlString:_urlString userPassword:_password];
    if ([self.delegate respondsToSelector:@selector(didStartRequest)]) {
        [self.delegate didStartRequest];
    }
}

- (void)clientAPIGetGroupes {
    [self.clientAPI loadGroupesOfHostsSuccess:^(NSArray *items) {
        DLog(@"NSArray *items");
    }                            failureBlock:^(NSError *error) {
        DLog(@"(NSError *error) == %@", error);
    }];
}

- (void)startLogin:(NSString *)userName urlString:(NSString *)urlString userPassword:(NSString *)userPassword {
    if (userPassword.length == 0 || urlString.length == 0 || userName.length == 0) {
        return;
    }
    NSString *newURLString = urlString;
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
        newURLString = [NSString stringWithFormat:@"%@%@", @"http://", urlString];
    }
    [self createNewClientWithURL:newURLString];
    
    BOOL isTrustedServer = self.currentServer.isTrustedSertificate;
    [_clientAPI loginWithUserName:userName password:userPassword trustedSertificate:isTrustedServer successBlock:^(NSArray *items) {
        [self didSuccessfullyLogin:userName password:userPassword andURL:urlString];
    }                failureBlock:^(NSError *error) {
        [self userdidFailLoginWithError:error];
    }];
}

- (void)cancelLoginRequest {
    [_client cancelAllHTTPOperationsWithMethod:nil path:nil];
}

- (void)logout {
    [Flurry logEvent:@"Logout pressed"];
    [_clientAPI logoutWithSuccessBlock:^(NSArray *items) {
        [self didSuccessfullyLogout];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error logout on server");
        [self didSuccessfullyLogout];
    }];
}

#pragma mark - Keychain Methods

- (void)saveCredentialsToKeychain:(NSString *)nameUser password:(NSString *)password {
    [Keychain saveString:nameUser forKey:kProtectedLoginKeyString];
    if ([[ZabbKitApplicationSettings sharedApplicationSettings] loginAutomatically]) {
        [Keychain saveString:password forKey:kProtectedPasswordKeyString];
    } else {
        [Keychain deleteStringForKey:kProtectedPasswordKeyString];
    }
}

- (void)saveUrlToKeychain:(NSString *)newUrl {
    [Keychain saveString:newUrl forKey:kProtectedURLKeyString];
}

- (void)saveCredentialsToKeychein {
    [Keychain saveString:self.nameUser forKey:kProtectedLoginKeyString];
    [Keychain saveString:self.password forKey:kProtectedPasswordKeyString];
}

- (void)removeCredentials {
    [Keychain deleteStringForKey:kProtectedPasswordKeyString];
}

#pragma mark - Result actions

- (void)didSuccessfullyLogin:(NSString *)name password:(NSString *)password andURL:(NSString *)urlString
{
    [Flurry logEvent:@"User was sign in successfully"];
    _userIsLoginIn = YES;
    _nameUser = name;
    _urlString = urlString;
    _password = password;
    [self saveNewZabbixServer];
    [self saveCredentialsToKeychain:name password:password];
    [self saveUrlToKeychain:urlString];
    if ([self.delegate respondsToSelector:@selector(didSuccessfullyLogin)]) {
        [self.delegate didSuccessfullyLogin];
    }
}

- (void)userdidFailLoginWithError:(NSError *)error
{
    _userIsLoginIn = NO;
    if ([self.delegate respondsToSelector:@selector(didFailLoginWithError:)]) {
        [self.delegate didFailLoginWithError:error];
    }
}

- (void)didSuccessfullyLogout
{
    _userIsLoginIn = NO;
    [self removeCredentials];
    if ([self.delegate respondsToSelector:@selector(didSuccessfullyLogout)]) {
        [self.delegate didSuccessfullyLogout];
    }
}

- (void)userdidFailLogoutWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(didFailLogoutWithError:)]) {
        [self.delegate didFailLogoutWithError:error];
    }
}

#pragma mark - Server Methods

- (void)saveNewZabbixServer {
    ZabbixServer *zabbixServer = [self serverFromListWithUrl:_urlString];
    if (zabbixServer == nil) {
        NSMutableArray *servers = [[ZabbKitApplicationSettings sharedApplicationSettings].zabbixServersArray mutableCopy];
        [servers addObject:self.currentServer];
        [ZabbKitApplicationSettings sharedApplicationSettings].zabbixServersArray = servers;
    }
}

- (void)makeTrustedServer
{
    ZabbixServer* zabbixServer = self.currentServer;
    zabbixServer.isTrustedSertificate = YES;
    NSMutableArray *zabbixServers = [[ZabbKitApplicationSettings sharedApplicationSettings].zabbixServersArray mutableCopy];
    NSInteger indexServer = [zabbixServers indexOfObjectPassingTest:^BOOL(ZabbixServer* server, NSUInteger idx, BOOL *stop) {
        return [server.url isEqualToString:_urlString];
    }];
    
    if (indexServer != NSNotFound) {
        [zabbixServers replaceObjectAtIndex:indexServer withObject:zabbixServer];
        [ZabbKitApplicationSettings sharedApplicationSettings].zabbixServersArray = zabbixServers;
    }
}

- (ZabbixServer*)serverFromListWithUrl:(NSString*)serverUrl
{
    ZabbixServer *zabbixServer = nil;
    NSArray *zabbixServers = [ZabbKitApplicationSettings sharedApplicationSettings].zabbixServersArray;
    NSInteger indexServer = [zabbixServers indexOfObjectPassingTest:^BOOL(ZabbixServer* server, NSUInteger idx, BOOL *stop) {
        return [server.url isEqualToString:_urlString];
    }];
    
    if (indexServer != NSNotFound) {
        zabbixServer = [zabbixServers objectAtIndex:indexServer];
    }
    return zabbixServer;
}


@end
