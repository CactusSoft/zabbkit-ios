//
//  ZabbixAPIRequest.h
//  Shtirlits
//
//  Created by Artem Bartle on 12/11/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZabbixRequestHelper : NSObject

@property(nonatomic, strong) NSString *authToken;
@property(nonatomic, assign) NSInteger userId;

- (id)initWithUrlString:(NSString *)urlString;

- (NSURLRequest *)loginRequestWithUsername:(NSString *)username
                                      pass:(NSString *)pass;

- (NSURLRequest *)logoutRequest;

- (NSURLRequest *)hostGroupsRequest;

- (NSURLRequest *)hostRequestWithGroupId:(NSString *)groupId;

- (NSURLRequest *)allHostsRequest;

- (NSURLRequest *)triggersRequestWithHostId:(NSString *)hostId;

- (NSURLRequest *)triggersRequestWithGroupId:(NSString *)groupId;
    
- (NSURLRequest *)triggersRequestWithIds:(NSSet *)triggersIds;

- (NSURLRequest *)allTrigersRequest;

- (NSURLRequest *)triggerEventsRequestWithTriggerId:(NSString *)triggerId;

- (NSURLRequest *)triggerEventsCountRequestWithTriggerId:(NSString *)triggerId;

- (NSURLRequest *)allEventsRequest;

- (NSURLRequest *)eventsRequestWithHostId:(NSString *)hostId;

- (NSURLRequest *)eventsRequestWithGroupId:(NSString *)groupId;

- (NSURLRequest *)hostGraphsRequestWithHostId:(NSString *)hostId;

- (NSURLRequest *)groupGraphsRequestWithGroupId:(NSString *)groupId;

- (NSURLRequest *)allGraphsRequest;

- (NSURLRequest *)hostItemsRequestWithHostId:(NSString *)hostId;

- (NSURLRequest *)groupItemsRequestWithGroupId:(NSString *)groupId;

- (NSURLRequest *)allItemsRequest;

- (NSURLRequest *)graphImageRequestWithGraphId:(NSString *)graphId
                                     imageSize:(CGSize)size
                                     timeRange:(NSTimeInterval)range
                                   currentDate:(NSDate *)currDate;

+ (NSURLRequest *)pushNotificationRegistrationWithToken:(NSString *)tokenDevice;

+ (NSURLRequest *)pushNotificationRenewToken:(NSString *)newTokenDevice
                                    oldToken:(NSString *)oldToken
                                      idPush:(NSString *)idPush;

@end
