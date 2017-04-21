//
//  ZabbixServer.h
//  Shtirlits
//
//  Created by bartle on 12/27/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZabbixServer : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *url;
@property(nonatomic, assign) BOOL isTrustedSertificate;

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (id)initWithUrl:(NSString*)urlString;

- (NSDictionary*)dictionary;

-(BOOL)isEqualToServer:(ZabbixServer *)server;

@end
