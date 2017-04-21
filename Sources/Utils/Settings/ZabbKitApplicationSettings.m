//
//  ShtirlitsApplicationSettings.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 22.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "ZabbKitApplicationSettings.h"
#import "Keychain.h"
#import "ZabbixServer.h"

static NSString *const kWebHostNameString = @"WebHostName";
static NSString *const kNameString = @"NameString";
static NSString *const kRememberUserCredentialsString = @"RememberUserCredentials";
static NSString *const kZabbixServer = @"ZabbixServers";
static NSString *const kProtectedNameServerKeyString = @"ShtirlitsProtectedNameServer";
static NSString *const kProtectedURLKeyString = @"ShtirlitsProtectedURL";
static NSString *const kApnsToken = @"ApnsToken";
static NSString *const kZabbkitToken = @"ZabbkitToken";

@interface ZabbKitApplicationSettings () {

}

@end

@implementation ZabbKitApplicationSettings

- (id)init {
    self = [super init];
    if (self) {
        [self initSettingsWithDefaults];
    }
    return self;
}

#pragma mark -

- (BOOL)loginAutomatically {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kRememberUserCredentialsString];
}

- (void)setLoginAutomatically:(BOOL)loginAutomatically {
    [[NSUserDefaults standardUserDefaults] setBool:loginAutomatically forKey:kRememberUserCredentialsString];
}

- (NSString *)nameUser {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kNameString];;
}

- (void)setNameUser:(NSString *)nameUser {
    [[NSUserDefaults standardUserDefaults] setObject:nameUser forKey:kNameString];
}

- (NSString *)urlString {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kWebHostNameString];
}

- (void)setUrlString:(NSString *)urlString {
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:kWebHostNameString];
}

- (NSArray *)zabbixServersArray {
    NSArray * serverDicts =  [[NSUserDefaults standardUserDefaults] arrayForKey:kZabbixServer];
    NSMutableArray *zabbixServers = [NSMutableArray arrayWithCapacity:serverDicts.count];
    for (NSDictionary *serverDict  in serverDicts) {
        ZabbixServer *zabbixServer = [[ZabbixServer alloc] initWithDictionary:serverDict];
        [zabbixServers addObject:zabbixServer];
    }
    return zabbixServers;
}

- (void)setZabbixServersArray:(NSArray *)zabbixServersArray {
    if (zabbixServersArray.count == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kZabbixServer];
        [Keychain deleteStringForKey:kProtectedURLKeyString];
        [Keychain deleteStringForKey:kProtectedNameServerKeyString];
    } else {
        NSMutableArray *zabbixDicts = [NSMutableArray arrayWithCapacity:zabbixServersArray.count];
        for (ZabbixServer *zabbixServer  in zabbixServersArray) {
            [zabbixDicts addObject:[zabbixServer dictionary]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:zabbixDicts forKey:kZabbixServer];
    }
}

- (NSString *)apnsToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kApnsToken];
}

- (void)setApnsToken:(NSString *)apnsToken {
    if (apnsToken == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kApnsToken];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:apnsToken forKey:kApnsToken];
    }
}

- (NSString *)zabkitToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kZabbkitToken];
}

- (void)setZabkitToken:(NSString *)zabkitToken {
    if (zabkitToken == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kZabbkitToken];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:zabkitToken forKey:kZabbkitToken];
    }
}

- (NSArray *)graphFavoritesForServer:(ZabbixServer*)server {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:server.url];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        return [NSArray array];
    }
}

- (void)setGraphFavorites:(NSArray *)graphFavorites forServer:(ZabbixServer*)server{
    if (graphFavorites.count == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:server.url];
    } else {
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:graphFavorites];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:server.url];
    }
}


#pragma mark - Helpers

- (void)initSettingsWithDefaults {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *pListPath = [path stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
    NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:pListPath];
    NSMutableArray *prefsArray = [pList objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *regDictionary = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in prefsArray) {
        NSString *key = [dict objectForKey:@"Key"];
        id value = [dict objectForKey:@"DefaultValue"];
        if (key && value) {
            [regDictionary setObject:value forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:regDictionary];

}

#pragma mark - Singleton Stuff

+ (ZabbKitApplicationSettings *)sharedApplicationSettings {
    static ZabbKitApplicationSettings *sharedSettings = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedSettings = [[super allocWithZone:NULL] init];
    });
    return sharedSettings;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedApplicationSettings];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
