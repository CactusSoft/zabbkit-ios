//
//  ZabbixUser.h
//  Shtirlits
//
//  Created by Artem Bartle on 12/7/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZabbixUser : NSObject

@property(nonatomic, assign) NSUInteger userId;
@property(nonatomic, copy) NSString *authToken;
@property(nonatomic, strong) NSArray *hostGroups;

@end
