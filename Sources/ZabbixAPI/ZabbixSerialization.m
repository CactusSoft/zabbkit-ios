//
//  ZabbixAPISerialization.m
//  Shtirlits
//
//  Created by Artem Bartle on 12/7/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "ZabbixSerialization.h"
#import "SerializationKeys.h"
#import "ZabbixUser.h"
#import "ZabbixHostGroup.h"
#import "ZabbixHost.h"
#import "ZabbixTrigger.h"
#import "ZabbixEvent.h"
#import "ZabbixGraph.h"
#import "ZabbixItem.h"
#import "DataSizeFormat.h"


@interface ZabbixSerialization ()

+ (NSDictionary *)dictionaryFromSelector:(SEL)selector withResponceData:(NSData *)data error:(NSError **)error;

@end

@implementation ZabbixSerialization

+ (NSDictionary *)dictionaryFromSelector:(SEL)selector withResponceData:(NSData *)data error:(NSError **)error {
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    if (*error) {
        return nil;
    }
    return responseDictionary;
}

+ (NSError *)errorWithReponseJSON:(NSDictionary *)responseDictionary {
    NSDictionary *errorDict = [responseDictionary objectForKey:kError];
    if (errorDict != nil) {
        NSString *code = [errorDict valueForKey:kErrorCode];
        NSString *data = [errorDict valueForKey:kErrorData];
        NSString *message = [errorDict valueForKey:kErrorMessage];
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        if (data != nil) {
            [userInfo setValue:data forKey:NSLocalizedDescriptionKey];
        }
        if (message != nil) {
            [userInfo setValue:message forKey:NSLocalizedFailureReasonErrorKey];
        }
        return [NSError errorWithDomain:NSLocalizedString(@"Zabbix Error", nil) code:code.integerValue userInfo:userInfo];
    }
    return nil;
}

+ (NSArray *)userWithResponseJSON:(NSDictionary *)responseDictionary {
    ZabbixUser *user = [ZabbixUser new];
    user.userId = [(NSString *) [responseDictionary objectForKey:kUserId] integerValue];
    user.authToken = [responseDictionary objectForKey:kResult];
    return [NSArray arrayWithObject:user];
}

+ (NSArray *)triggersWithResponseJSON:(NSDictionary *)responseDictionary {
    NSArray *resultArray = [responseDictionary objectForKey:kResult];
    NSMutableArray *triggers = [NSMutableArray array];

    for (NSDictionary *triggerDict in resultArray) {
        ZabbixTrigger *trigger = [ZabbixTrigger new];
        trigger.triggerid = [triggerDict objectForKey:kTriggerId];
        trigger.triggerDescription = [triggerDict objectForKey:kTriggerDescription];
        trigger.priority = [(NSNumber *) [triggerDict objectForKey:kTriggerPriority] integerValue];
        trigger.value = [(NSNumber *) [triggerDict objectForKey:kTriggerValue] integerValue];
        trigger.url = [triggerDict objectForKey:kTriggerUrl];
        trigger.comments = [triggerDict objectForKey:kTriggerComments];
        if ((NSArray *) [triggerDict objectForKey:kTriggerHosts]) {
            trigger.hosts = (NSArray *) [triggerDict objectForKey:kTriggerHosts];
        }
        [triggers addObject:trigger];
    }
    return triggers;
}

+ (NSArray *)hostGroupsWithResponseJSON:(NSDictionary *)responseDictionary {
    NSArray *resultArray = [responseDictionary objectForKey:kResult];
    NSMutableArray *groups = [NSMutableArray array];

    for (NSDictionary *groupDict in resultArray) {
        ZabbixHostGroup *group = [ZabbixHostGroup new];
        group.groupId = [groupDict objectForKey:kGroupId];
        group.groupName = [groupDict objectForKey:kGroupName];
        [groups addObject:group];
    }
    return groups;
}

+ (NSArray *)hostsWithResponseJSON:(NSDictionary *)responseDictionary {
    NSArray *resultArray = [responseDictionary objectForKey:kResult];
    NSMutableArray *hosts = [NSMutableArray array];

    for (NSDictionary *hostDict in resultArray) {
        ZabbixHost *host = [ZabbixHost new];
        host.hostName = [hostDict objectForKey:kHostName];
        host.hostId = [hostDict objectForKey:kHostId];
        [hosts addObject:host];
    }
    return hosts;
}

+ (NSArray *)eventsWithResponseJSON:(NSDictionary *)responseDictionary {
    NSArray *resultArray = [responseDictionary objectForKey:kResult];
    NSMutableArray *events = [NSMutableArray array];
    for (NSDictionary *eventDict in resultArray) {
        ZabbixEvent *event = [ZabbixEvent new];
        event.eventid = [eventDict objectForKey:kEventId];
        event.clock = [[eventDict objectForKey:kEventClock] doubleValue];
        event.objectid = [eventDict objectForKey:kEventObjectId];
        event.value = [[eventDict objectForKey:kEventValue] integerValue];
        [events addObject:event];
    }
    return events;
}

+ (NSArray *)graphsWithResponseJSON:(NSDictionary *)responseDictionary {
    NSArray *resultArray = [responseDictionary objectForKey:kResult];
    NSMutableArray *graphs = [NSMutableArray array];
    for (NSDictionary *graphDict in resultArray) {
        ZabbixGraph *graph = [ZabbixGraph new];
        graph.graphId = [graphDict valueForKey:kGraphId];
        graph.graphName = [graphDict valueForKey:kGraphName];
        [graphs addObject:graph];
    }
    return graphs;
}

+ (NSString*)itemNameWithFormat:(NSString*)template keys:(NSString*)keys {
    NSRange start = [keys rangeOfString:@"["];
    start.location += 1;
    NSRange end = [keys rangeOfString:@"]" options:NSBackwardsSearch];
    end.location -= 1;
    if (start.location != NSNotFound && end.location != NSNotFound && start.location < end.location) {
        NSString* keysString = [keys substringWithRange:NSMakeRange(start.location, end.location - start.location + 1)];
        NSArray* keysArray = [keysString componentsSeparatedByString:@","];
        NSUInteger index = 0;
        NSMutableString* result = [template mutableCopy];
        for (NSString* key in keysArray) {
            index++;
            [result replaceOccurrencesOfString:[NSString stringWithFormat:@"$%d", index] withString:key options:NSLiteralSearch range:NSMakeRange(0, result.length)];
        }
        return result;
    } else {
        return template;
    }
}

+ (NSArray *)itesmsWithResponseJSON:(NSDictionary *)responseDictionary
{
    NSArray* resultArray = [responseDictionary objectForKey:kResult];
    NSMutableArray* items = [NSMutableArray array];
    for (NSDictionary* itemDict in resultArray) {
        ZabbixItem* item = [ZabbixItem new];
        item.itemId = [itemDict valueForKey:kItemId];
        item.lastValue = [itemDict objectForKey:kItemLastValue];
        item.valueUnits = [itemDict valueForKey:kItemValueUnits];
        
        switch ([[itemDict objectForKey:kItemValueType] integerValue]) {
            case 0: {
                double value = item.lastValue.doubleValue;
                NSString* units = item.valueUnits;
                if ([item.valueUnits isEqualToString:@"unixtime"]) {
                    [DataSizeFormat formatUnixTime:value resultValue:&units];
                    item.valueType = ZabbixItemValueType_string;
                    item.lastValue = units;
                    item.valueUnits = nil;
                } else {
                    item.valueType = ZabbixItemValueType_float;
                    NSString* units = item.valueUnits;
                    if ([item.valueUnits isEqualToString:@"bps"]) {
                        [DataSizeFormat formatBitsPerSecond:value resultValue:&value units:&units];
                    } else if ([item.valueUnits isEqualToString:@"Bps"]) { // rate in byes per second
                        [DataSizeFormat formatBytesPerSecond:value resultValue:&value units:&units];
                    } else if ([item.valueUnits isEqualToString:@"B"]) { // storage size in bytes
                        [DataSizeFormat formatBytes:value resultValue:&value units:&units];
                    } else if ([item.valueUnits isEqualToString:@"uptime"]) { // time
                        [DataSizeFormat formatUpTime:value resultValue:&value units:&units];
                    }
                    item.valueUnits = units;
                    item.lastValue = [NSString stringWithFormat:@"%.2f", value];
                }
            } break;
            case 3: {
                double value = item.lastValue.doubleValue;
                NSString* units = item.valueUnits;
                if ([item.valueUnits isEqualToString:@"unixtime"]) {
                    [DataSizeFormat formatUnixTime:value resultValue:&units];
                    item.valueType = ZabbixItemValueType_string;
                    item.lastValue = units;
                    item.valueUnits = nil;
                } else {
                    item.valueType = ZabbixItemValueType_uint;
                    NSString* units = item.valueUnits;
                    if ([item.valueUnits isEqualToString:@"bps"]) {
                        [DataSizeFormat formatBitsPerSecond:value resultValue:&value units:&units];
                    } else if ([item.valueUnits isEqualToString:@"Bps"]) { // rate in byes per second
                        [DataSizeFormat formatBytesPerSecond:value resultValue:&value units:&units];
                    } else if ([item.valueUnits isEqualToString:@"B"]) { // storage size in bytes
                        [DataSizeFormat formatBytes:value resultValue:&value units:&units];
                    } else if ([item.valueUnits isEqualToString:@"uptime"]) { // time
                        [DataSizeFormat formatUpTime:value resultValue:&value units:&units];
                    }
                    item.valueUnits = units;
                    NSUInteger intValue = round(value);
                    item.lastValue = [NSString stringWithFormat:@"%d", intValue];
                }
            } break;
            case 1:
            case 2:
            case 4:
                item.valueType = ZabbixItemValueType_string;
                break;
            default:
                item.valueType = ZabbixItemValueType_unknown;
                break;
        }
        
        // item name
        NSString* format = [itemDict valueForKey:kItemName];
        NSString* keys = [itemDict valueForKey:kItemKey];
        item.itemName = [self itemNameWithFormat:format keys:keys];
        
        // item graph
        NSArray* graphs = [itemDict objectForKey:kItemGraphs];
        if (graphs.count > 0) {
            NSDictionary* graphDict = [graphs objectAtIndex:0];
            ZabbixGraph* graph = [[ZabbixGraph alloc] init];
            graph.graphId = [graphDict valueForKey:kGraphId];
            graph.graphName = [graphDict valueForKey:kGraphName];
            item.graph = graph;
        }
        
        // item host
        NSArray* hosts = [itemDict objectForKey:kItemHosts];
        if (hosts.count > 0) {
            NSDictionary* hostDict = [hosts objectAtIndex:0];
            ZabbixHost* host = [[ZabbixHost alloc] init];
            host.hostId = [hostDict valueForKey:kHostId];
            host.hostName = [hostDict valueForKey:kHostName];
            item.host = host;
        }
        
        [items addObject:item];
    }
    return items;
}

@end
