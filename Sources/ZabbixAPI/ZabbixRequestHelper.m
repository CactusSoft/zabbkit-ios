//
//  ZabbixAPIRequest.m
//  Shtirlits
//
//  Created by Artem Bartle on 12/11/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "ZabbixRequestHelper.h"

static NSTimeInterval kRequestTimeoutInterval = 20.f;
static NSInteger kRequestLimit = 1000;

//static NSString *kURLPushNotif = urlServerPush;
//static NSString *kURLPushNotifRenewToken = @"http://vserver.inside.cactussoft.biz/zabbkit-test/api/apns";
//static NSString *kURLPushNotif = @"http://vserver:80/api/devices";

static NSString *kBodyPushNotif = @"{type:0,Token:\"%@\"}";
static NSString *kBodyPushNotifRenew = @"{type:'iOS', id:'%@', oldToken:'%@', newToken:'%@'}";

static NSString *kGraphImageRequestTemplate = @"chart2.php?graphid=%@&width=%d&height=%d&period=%.0f&stime=%.0f";

static NSString *const kRequestPlistFileName = @"requests";
// Keys
static NSString *const kLoginRequestKey = @"user.login";
static NSString *const kLogoutRequestKey = @"user.logout";

static NSString *const kGetHostGroupsKey = @"hostgroups.get";
static NSString *const kGetHostsKey = @"hosts.get";
static NSString *const kGetAllHostsKey = @"allhosts.get";

static NSString *const kGetTriggerByIdsKey = @"trigger.getByIds";
static NSString *const kGetHostTriggersKey = @"host.getTriggers";
static NSString *const kGetGroupTriggersKey = @"group.getTriggers";
static NSString *const kGetAllTriggersKey = @"alltriggers.get";

static NSString *const kGetTriggerEventsKey = @"event.get";
static NSString *const kGetTriggerEventsCountKey = @"eventsCount.get";
static NSString *const kGetAllEventsKey = @"allevents.get";
static NSString *const kGetHostEventsKey = @"host.getEvents";
static NSString *const kGetGroupEventsKey = @"group.getEvents";

static NSString *const kGetHostGraphsKey = @"hostgraphs.get";
static NSString *const kGetGroupGraphsKey = @"groupgraphs.get";
static NSString *const kGetAllGraphsKey = @"allgraphs.get";

static NSString *const kGetHostItemsKey = @"hostitems.get";
static NSString *const kGetGroupItemsKey = @"groupitems.get";
static NSString *const kGetAllItemsKey = @"allitems.get";

@interface ZabbixRequestHelper () {
    NSDictionary *requestsTemplatesDictionary_;
    NSMutableURLRequest *templateRequest_;
    NSString *urlString_;
}

@end


@implementation ZabbixRequestHelper
@synthesize authToken = authToken_;
@synthesize userId = userId_;

- (id)initWithUrlString:(NSString *)urlString {
    self = [super init];
    if (self) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:kRequestPlistFileName
                                                              ofType:@"plist"];
        NSAssert1(plistPath, @"Couldn't find %@.plist", kRequestPlistFileName);
        requestsTemplatesDictionary_ = [NSDictionary dictionaryWithContentsOfFile:plistPath];

        urlString_ = urlString;
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"api_jsonrpc.php"]];
        templateRequest_ = [NSMutableURLRequest requestWithURL:url
                                                   cachePolicy:NSURLRequestReloadIgnoringCacheData
                                               timeoutInterval:kRequestTimeoutInterval];
        templateRequest_.HTTPMethod = @"POST";
        [templateRequest_ addValue:@"application/json-rpc"
                forHTTPHeaderField:@"Content-Type"];
    }
    return self;
}

#pragma mark - Login/logout requests

- (NSURLRequest *)loginRequestWithUsername:(NSString *)username
                                      pass:(NSString *)pass {
    NSString *requestTemplate =
            [requestsTemplatesDictionary_ objectForKey:kLoginRequestKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kLoginRequestKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate,
                                                         username,
                                                         pass];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)logoutRequest {
    NSString *requestTemplate =
            [requestsTemplatesDictionary_ objectForKey:kLogoutRequestKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kLogoutRequestKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate,
                                                         self.userId,
                                                         self.authToken];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

#pragma mark - Hostgroups/Hosts requests

- (NSURLRequest *)hostGroupsRequest {
    NSString *requestTemplate =
            [requestsTemplatesDictionary_ objectForKey:kGetHostGroupsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetHostGroupsKey);
    NSString *requestString =
            [NSString stringWithFormat:requestTemplate,
                                       self.authToken,
                                       self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)hostRequestWithGroupId:(NSString *)groupId {
    NSString *requestTemplate =
            [requestsTemplatesDictionary_ objectForKey:kGetHostsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetHostsKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate,
                                                         groupId,
                                                         self.authToken,
                                                         self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)allHostsRequest {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetAllHostsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetAllHostsKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate, self.authToken, self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

#pragma mark - Triggers

- (NSURLRequest *)triggersRequestWithGroupId:(NSString *)groupId {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetGroupTriggersKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetGroupTriggersKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate,
                                                         groupId,
                                                         self.authToken,
                                                         self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)triggersRequestWithIds:(NSSet *)triggersIds {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetTriggerByIdsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetTriggerByIdsKey);
    
    NSMutableString* triggers = [NSMutableString string];
    [triggersIds.allObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != 0) {
            [triggers appendFormat:@",\"%@\"", (NSString*)obj];
        } else {
            [triggers appendFormat:@"\"%@\"", (NSString*)obj];
        }
    }];
    NSString *requestString = [NSString stringWithFormat:requestTemplate, triggers, self.authToken, self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)triggersRequestWithHostId:(NSString *)hostId {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetHostTriggersKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetHostTriggersKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate,
                                                         hostId,
                                                         self.authToken,
                                                         self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)allTrigersRequest {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetAllTriggersKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetAllTriggersKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate, self.authToken, self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

#pragma mark - Events

- (NSURLRequest *)triggerEventsRequestWithTriggerId:(NSString *)triggerId {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetTriggerEventsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetTriggerEventsKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate,
                                                         triggerId,
                                                         self.authToken,
                                                         self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)triggerEventsCountRequestWithTriggerId:(NSString *)triggerId {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetTriggerEventsCountKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetTriggerEventsCountKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate,
                                                         triggerId,
                                                         self.authToken,
                                                         self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)allEventsRequest {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetAllEventsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetAllEventsKey);
    NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
    ti -= 3600 * 24 * 30;
    NSString *requestString = [NSString stringWithFormat:requestTemplate, ti, self.authToken, self.userId, kRequestLimit];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)eventsRequestWithHostId:(NSString *)hostId {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetHostEventsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetHostEventsKey);
    NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
    ti -= 3600 * 24 * 30;
    NSString *requestString = [NSString stringWithFormat:requestTemplate, hostId, ti, self.authToken, self.userId, kRequestLimit];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)eventsRequestWithGroupId:(NSString *)groupId {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetGroupEventsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetGroupEventsKey);
    NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
    ti -= 3600 * 24 * 30;
    NSString *requestString = [NSString stringWithFormat:requestTemplate, groupId, ti, self.authToken, self.userId, kRequestLimit];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

#pragma mark - Graphs

- (NSURLRequest *)hostGraphsRequestWithHostId:(NSString *)hostId {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetHostGraphsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetHostGraphsKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate, hostId, self.authToken, self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)groupGraphsRequestWithGroupId:(NSString *)groupId {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetGroupGraphsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetGroupGraphsKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate, groupId, self.authToken, self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)allGraphsRequest {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetAllGraphsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetAllGraphsKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate, self.authToken, self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

#pragma mark - Items

- (NSURLRequest *)hostItemsRequestWithHostId:(NSString *)hostId {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetHostItemsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetHostGraphsKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate, hostId, self.authToken, self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)groupItemsRequestWithGroupId:(NSString *)groupId {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetGroupItemsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetGroupItemsKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate, groupId, self.authToken, self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)allItemsRequest {
    NSString *requestTemplate = [requestsTemplatesDictionary_ objectForKey:kGetAllItemsKey];
    NSAssert1(requestTemplate, @"%@ template is nil", kGetAllItemsKey);
    NSString *requestString = [NSString stringWithFormat:requestTemplate, self.authToken, self.userId];
    NSMutableURLRequest *request = [templateRequest_ copy];
    request.timeoutInterval = kRequestTimeoutInterval;
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest *)graphImageRequestWithGraphId:(NSString *)graphId
                                     imageSize:(CGSize)size
                                     timeRange:(NSTimeInterval)range
                                   currentDate:(NSDate *)currDate {
    NSTimeInterval timestamp;
    if (currDate) {
        timestamp = [currDate timeIntervalSince1970];
    } else {
        timestamp = [[NSDate date] timeIntervalSince1970];
    }

    NSString *urlTemplate = [urlString_ stringByAppendingPathComponent:kGraphImageRequestTemplate];
    NSString *urlString = [NSString stringWithFormat:urlTemplate,
                                                     graphId,
                                                     (NSUInteger) size.width,
                                                     (NSUInteger) size.height,
                                                     range,
                                                     timestamp - range];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = kRequestTimeoutInterval;
    NSDictionary *properties = @{
            NSHTTPCookieOriginURL : urlString_,
            NSHTTPCookiePath : @"/",
            NSHTTPCookieName : @"zbx_sessionid",
            NSHTTPCookieValue : self.authToken
    };
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:@[cookie]];
    [request setAllHTTPHeaderFields:headers];
    return request;
}

#pragma mark Push Notification
+ (NSURLRequest *)pushNotificationRegistrationWithToken:(NSString *)tokenDevice {
    NSURL *url = [NSURL URLWithString:urlServerPush];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = kRequestTimeoutInterval;
    NSString *requestString = [NSString stringWithFormat:kBodyPushNotif, tokenDevice];
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json"
   forHTTPHeaderField:@"Content-type"];
    return request;
}

+ (NSURLRequest *)pushNotificationRenewToken:(NSString *)newTokenDevice oldToken:(NSString *)oldToken idPush:(NSString *)idPush {
    NSURL *url = [NSURL URLWithString:urlServerPush];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = kRequestTimeoutInterval;
    NSString *requestString = [NSString stringWithFormat:kBodyPushNotifRenew, idPush, oldToken, newTokenDevice];
    request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"PUT";
    [request addValue:@"application/json"
   forHTTPHeaderField:@"Content-type"];
    return request;

}

@end
