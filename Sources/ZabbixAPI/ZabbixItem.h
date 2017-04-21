//
//  ZabbixItem.h
//  Zabbkit
//
//  Created by Alexey Dozortsev on 20.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZabbixHost;
@class ZabbixGraph;

typedef enum {
    ZabbixItemValueType_float,
    ZabbixItemValueType_uint,
    ZabbixItemValueType_string,
    ZabbixItemValueType_unknown
} ZabbixItemValueType;

@interface ZabbixItem : NSObject

@property(nonatomic, strong) NSString* itemId;
@property(nonatomic, strong) NSString* itemName;
@property(nonatomic, assign) ZabbixItemValueType valueType;
@property(nonatomic, strong) NSString* lastValue;
@property(nonatomic, strong) NSString* valueUnits;
@property(nonatomic, strong) ZabbixHost* host;
@property(nonatomic, strong) ZabbixGraph* graph;


@end
