//
//  ZabbixClientAPI.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 30.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "ZabbixClientAPI.h"
#import "ZabbixSerialization.h"
#import "ZabbixUser.h"
#import "AFJSONRequestOperation.h"
#import "ZabbixHostGroup.h"
#import "ZabbixHost.h"
#import "AFJSONRequestOperation+AlternativeBlocks.h"
#import "Flurry.h"

@interface ZabbixClientAPI () {

}
@property(nonatomic, strong) AFJSONRequestOperation *requestOperation;

@end

@implementation ZabbixClientAPI

@synthesize user = user_;
@synthesize requestOperation = requestOperation_;
@synthesize requestHelper = requestHelper_;

- (id)init {
    self = [super init];
    if (self) {
        requestHelper_ = [ZabbixRequestHelper new];
    }
    return self;
}

- (void)setUser:(ZabbixUser *)user {
    if (user) {
        user_ = user;
        self.requestHelper.authToken = user.authToken;
        self.requestHelper.userId = user.userId;
        requestOperation_ = [[AFJSONRequestOperation alloc] init];
    }
}

- (void (^)(AFJSONRequestOperation *, id))blockForLoadingItems:(void (^)(NSArray *))success
                                                  failureBlock:(void (^)(NSError *error))failureLoadBlock
                                            typeResponceObject:(ZabbixClientAPIResultObject)typeObj {
    void (^resultBlock)(AFJSONRequestOperation *operation, id object) = ^void(AFJSONRequestOperation *operation, id object) {
        NSError *error = [ZabbixSerialization errorWithReponseJSON:object];
        if (error) {
            failureLoadBlock(error);
        } else {
            switch (typeObj) {
                case ZabbixClientAPIResultObjectUser: {
                    NSArray *userArray = [ZabbixSerialization userWithResponseJSON:object];
                    self.user = [userArray lastObject];
                    success(userArray);
                }
                    break;
                case ZabbixClientAPIResultObjectLogout:
                    success(nil);
                    break;
                case ZabbixClientAPIResultObjectTrigger:
                    success([ZabbixSerialization triggersWithResponseJSON:object]);
                    break;
                case ZabbixClientAPIResultObjectGroup:
                    success([ZabbixSerialization hostGroupsWithResponseJSON:object]);
                    break;
                case ZabbixClientAPIResultObjectHost:
                    success([ZabbixSerialization hostsWithResponseJSON:object]);
                    break;
                case ZabbixClientAPIResultObjectEvent:
                    success([ZabbixSerialization eventsWithResponseJSON:object]);
                    break;
                case ZabbixClientAPIResultObjectGraph:
                    success([ZabbixSerialization graphsWithResponseJSON:object]);
                    break;
                case ZabbixClientAPIResultObjectItem:
                    success([ZabbixSerialization itesmsWithResponseJSON:object]);
                    break;
            }
        }
    };
    return resultBlock;
}

- (void (^)(AFJSONRequestOperation *operation, NSError *error, id JSON))blockForFailureResponse:(void (^)(NSError *))errorBlock {
    void (^resultBlock)(AFJSONRequestOperation *operation, NSError *error, id JSON) = ^(AFJSONRequestOperation *operation, NSError *error, id JSON) {
        if (operation.isCancelled) {
            errorBlock(nil);
        } else {
            if (operation.response.statusCode / 100 != 2) {
                [Flurry logError:@"ZabbKit Error (failure)" message:[NSString stringWithFormat:@"%@", operation.responseString] error:error];
            }
            switch (error.code) {
                case -1016: {
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
                    [userInfo setValue:@"Invalid response from server" forKey:NSLocalizedDescriptionKey];
                    [userInfo setValue:@"Unexpected response from server" forKey:NSLocalizedFailureReasonErrorKey];
                    [userInfo setValue:@"Ensure that you enter correct zabbix URL" forKey:NSLocalizedRecoverySuggestionErrorKey];
                    errorBlock([NSError errorWithDomain:@"Zabbkit Error" code:-1016 userInfo:userInfo]);
                } break;
                    
                default:
                    errorBlock(error);
                    break;
            }
        }
    };
    return resultBlock;
}

#pragma mark Hostgroups / Hosts

- (void)loginWithUserName:(NSString *)username password:(NSString *)password trustedSertificate:(BOOL)trustSertificate successBlock:(void (^)(NSArray *items))successLoadBlock failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ loginRequestWithUsername:username pass:password]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectUser]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    requestOperation_.allowsInvalidSSLCertificate = trustSertificate;
    [requestOperation_ start];
}

- (void)logoutWithSuccessBlock:(void (^)(NSArray *items))successLoadBlock failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ logoutRequest]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectLogout]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadGroupesOfHostsSuccess:(void (^)(NSArray *items))successLoadBlock
                     failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ hostGroupsRequest]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectGroup]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadHostsWithGroupId:(NSString *)groupId
                     success:(void (^)(NSArray *items))successLoadBlock
                failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ hostRequestWithGroupId:groupId]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectHost]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadAllHostsSuccess:(void (^)(NSArray *items))successLoadBlock
               failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ allHostsRequest]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectHost]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

#pragma mark - Triggers

- (void)loadTriggersWithIds:(NSSet *)triggerIds success:(void (^)(NSArray *items))successLoadBlock failureBlock:(void (^)(NSError *error))failureLoadBlock
{
    NSOperation *operation = [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ triggersRequestWithIds:triggerIds]
                                                                                    success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectTrigger]
                                                                                    failure:[self blockForFailureResponse:failureLoadBlock]];
    [operation performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
}

- (void)loadTriggersWithHostId:(NSString *)hostId
                       success:(void (^)(NSArray *items))successLoadBlock
                  failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ triggersRequestWithHostId:hostId]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectTrigger]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadTriggersWithGroupId:(NSString *)groupId
                        success:(void (^)(NSArray *items))successLoadBlock
                   failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ triggersRequestWithGroupId:groupId]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectTrigger]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadAllTrigersSuccess:(void (^)(NSArray *items))successLoadBlock
                 failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ allTrigersRequest]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectTrigger]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

#pragma mark - Events

- (void)loadTriggerEventsWithTriggerId:(NSString *)triggerId
                               success:(void (^)(NSArray *items))successLoadBlock
                          failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ triggerEventsRequestWithTriggerId:triggerId]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectEvent]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadAllEventsSuccess:(void (^)(NSArray *items))successLoadBlock
                failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ allEventsRequest]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectEvent]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadEventsWithHostId:(NSString *)hostId success:(void (^)(NSArray *items))successLoadBlock
                failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ eventsRequestWithHostId:hostId]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectEvent]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadEventsWithGroupId:(NSString *)groupId success:(void (^)(NSArray *items))successLoadBlock
                 failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ eventsRequestWithGroupId:groupId]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectEvent]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

#pragma mark - Graphs

- (void)loadGraphsWithHostId:(NSString *)hostId
                     success:(void (^)(NSArray *items))successLoadBlock
                failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ hostGraphsRequestWithHostId:hostId]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectGraph]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadGraphsWithGroupId:(NSString *)groupId
                      success:(void (^)(NSArray *items))successLoadBlock
                 failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ groupGraphsRequestWithGroupId:groupId]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectGraph]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadAllGraphsWithSuccess:(void (^)(NSArray *items))successLoadBlock
                    failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
            [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ allGraphsRequest]
                                                                   success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectGraph]
                                                                   failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

#pragma mark - Items

- (void)loadItemsWithHostId:(NSString *)hostId
                    success:(void (^)(NSArray *items))successLoadBlock
               failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
    [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ hostItemsRequestWithHostId:hostId]
                                                           success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectItem]
                                                           failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadItemsWithGroupId:(NSString *)groupId
                     success:(void (^)(NSArray *items))successLoadBlock
                failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
    [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ groupItemsRequestWithGroupId:groupId]
                                                           success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectItem]
                                                           failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

- (void)loadAllItemsWithSuccess:(void (^)(NSArray *items))successLoadBlock
                   failureBlock:(void (^)(NSError *error))failureLoadBlock {
    [requestOperation_ cancel];
    requestOperation_ =
    [AFJSONRequestOperation ZabbKitJSONRequestOperationWithRequest:[requestHelper_ allItemsRequest]
                                                           success:[self blockForLoadingItems:successLoadBlock failureBlock:failureLoadBlock typeResponceObject:ZabbixClientAPIResultObjectItem]
                                                           failure:[self blockForFailureResponse:failureLoadBlock]];
    [requestOperation_ start];
}

@end
