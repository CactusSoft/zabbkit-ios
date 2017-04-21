//
//  ShtirlitsApplicationSettings.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 22.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZabbixServer;

@interface ZabbKitApplicationSettings : NSObject

@property(nonatomic, assign) NSString *nameUser;
@property(nonatomic, assign) NSString *urlString;
@property(nonatomic, assign) NSArray *zabbixServersArray;
@property(nonatomic, assign) BOOL loginAutomatically;
@property(nonatomic, assign) NSString *apnsToken;
@property(nonatomic, assign) NSString *zabkitToken;

- (NSArray *)graphFavoritesForServer:(ZabbixServer*)server;
- (void)setGraphFavorites:(NSArray *)graphFavorites forServer:(ZabbixServer*)server;

+ (ZabbKitApplicationSettings *)sharedApplicationSettings;

@end
