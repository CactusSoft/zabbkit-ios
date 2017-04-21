//
//  ZabbixServer.m
//  Shtirlits
//
//  Created by bartle on 12/27/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "ZabbixServer.h"

static NSString *const kNameServer = @"NameSrver";
static NSString *const kUrlServer = @"URLServer";
static NSString *const kTrustSertificate = @"TrustSertificate";
static NSString *const kDefaultNameServer = @"Zabbix Server";

@implementation ZabbixServer

- (id)init
{
    self = [super init];
    if (self) {
        _name = kDefaultNameServer;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self) {
        _name = [dictionary objectForKey:kNameServer];
        _url = [dictionary objectForKey:kUrlServer];
        _isTrustedSertificate = ((NSNumber*)[dictionary objectForKey:kTrustSertificate]).boolValue;
    }
    return self;
}

- (id)initWithUrl:(NSString*)urlString;
{
    self = [self init];
    if (self) {
        _url = urlString;
    }
    return self;
}

- (NSDictionary*)dictionary
{
    NSMutableDictionary *mDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    [mDictionary setObject:_name forKey:kNameServer];
    [mDictionary setObject:_url forKey:kUrlServer];
    [mDictionary setObject:[NSNumber numberWithBool:_isTrustedSertificate] forKey:kTrustSertificate];
    return [mDictionary copy];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"name - %@\nurl - %@\nisTrusted - %s",_name,_url,_isTrustedSertificate ? "YES" : "NO"];
}

-(BOOL)isEqualToServer:(ZabbixServer *)server
{
    if (self == server) return YES;
    
    if (![_name isEqualToString:server.name])
        return NO;
    if (![_url isEqualToString:server.url])
        return NO;
    if (_isTrustedSertificate != server.isTrustedSertificate)
        return NO;
    return YES;
}

-(BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return [self isEqualToServer:object];
    } else {
        return [super isEqual:object];
    }
}

@end
