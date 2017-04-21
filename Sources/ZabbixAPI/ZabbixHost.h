//
//  ZabbixHost.h
//  Shtirlits
//
//  Created by Artem Bartle on 12/7/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZabbixHost : NSObject

@property(nonatomic, strong) NSString *hostName;
@property(nonatomic, strong) NSString *hostId;

@end
