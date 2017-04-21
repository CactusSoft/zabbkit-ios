//
//  ZabbixClientAPI.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 30.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZabbixRequestHelper.h"

@class ZabbixUser;
@class ZabbixRequestHelper;

typedef enum {
    ZabbixClientAPIResultObjectUser,
    ZabbixClientAPIResultObjectLogout,
    ZabbixClientAPIResultObjectTrigger,
    ZabbixClientAPIResultObjectEvent,
    ZabbixClientAPIResultObjectGroup,
    ZabbixClientAPIResultObjectHost,
    ZabbixClientAPIResultObjectGraph,
    ZabbixClientAPIResultObjectItem
} ZabbixClientAPIResultObject;

@interface ZabbixClientAPI : NSObject

@property(nonatomic, strong) ZabbixUser *user;
@property(nonatomic, strong) ZabbixRequestHelper *requestHelper;

- (void)loginWithUserName:(NSString *)username password:(NSString *)password
         trustedSertificate:(BOOL)trustSertificate
             successBlock:(void (^)(NSArray *items))successLoadBlock
             failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)logoutWithSuccessBlock:(void (^)(NSArray *items))successLoadBlock
                  failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadGroupesOfHostsSuccess:(void (^)(NSArray *items))successLoadBlock
                     failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadHostsWithGroupId:(NSString *)groupId
                     success:(void (^)(NSArray *items))successLoadBlock
                failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadTriggersWithIds:(NSSet *)triggerIds
                    success:(void (^)(NSArray *items))successLoadBlock
               failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadTriggersWithHostId:(NSString *)hostId
                       success:(void (^)(NSArray *items))successLoadBlock
                  failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadTriggersWithGroupId:(NSString *)groupId
                        success:(void (^)(NSArray *items))successLoadBlock
                   failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadAllHostsSuccess:(void (^)(NSArray *items))successLoadBlock
               failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadAllTrigersSuccess:(void (^)(NSArray *items))successLoadBlock
                 failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadTriggerEventsWithTriggerId:(NSString *)triggerId
                               success:(void (^)(NSArray *items))successLoadBlock
                          failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadAllEventsSuccess:(void (^)(NSArray *items))successLoadBlock
                failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadEventsWithGroupId:(NSString *)hostId
                      success:(void (^)(NSArray *items))successLoadBlock
                 failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadEventsWithHostId:(NSString *)hostId
                     success:(void (^)(NSArray *items))successLoadBlock
                failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadGraphsWithHostId:(NSString *)hostId
                     success:(void (^)(NSArray *items))successLoadBlock
                failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadGraphsWithGroupId:(NSString *)groupId
                      success:(void (^)(NSArray *items))successLoadBlock
                 failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadAllGraphsWithSuccess:(void (^)(NSArray *items))successLoadBlock
                    failureBlock:(void (^)(NSError *error))failureLoadBlock;


- (void)loadItemsWithHostId:(NSString *)hostId
                    success:(void (^)(NSArray *items))successLoadBlock
               failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadItemsWithGroupId:(NSString *)groupId
                     success:(void (^)(NSArray *items))successLoadBlock
                failureBlock:(void (^)(NSError *error))failureLoadBlock;

- (void)loadAllItemsWithSuccess:(void (^)(NSArray *items))successLoadBlock
                   failureBlock:(void (^)(NSError *error))failureLoadBlock;

@end
