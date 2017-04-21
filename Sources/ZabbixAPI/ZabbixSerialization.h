//
//  ZabbixAPISerialization.h
//  Shtirlits
//
//  Created by Artem Bartle on 12/7/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZabbixClientAPI.h"

@class ZabbixUser;

@interface ZabbixSerialization : NSObject

+ (NSError *)errorWithReponseJSON:(NSDictionary *)responseDictionary;

+ (NSArray *)userWithResponseJSON:(NSDictionary *)responseDictionary;

+ (NSArray *)triggersWithResponseJSON:(NSDictionary *)responseDictionary;

+ (NSArray *)hostGroupsWithResponseJSON:(NSDictionary *)responseDictionary;

+ (NSArray *)hostsWithResponseJSON:(NSDictionary *)responseDictionary;

+ (NSArray *)eventsWithResponseJSON:(NSDictionary *)responseDictionary;

+ (NSArray *)graphsWithResponseJSON:(NSDictionary *)responseDictionary;

+ (NSArray *)itesmsWithResponseJSON:(NSDictionary *)responseDictionary;

@end
