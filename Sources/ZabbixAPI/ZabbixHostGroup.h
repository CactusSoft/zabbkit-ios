//
//  ZabbixHostGroup.h
//  Shtirlits
//
//  Created by Artem Bartle on 12/7/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZabbixHostGroup : NSObject

@property(nonatomic, strong) NSString *groupId;
@property(nonatomic, strong) NSString *groupName;

@end
