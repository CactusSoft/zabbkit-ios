//
//  ZabbixTrigger.h
//  Shtirlits
//
//  Created by Artem Bartle on 12/7/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZabbixHost.h"
/*
Value
Value 	Type
0	      OK
1	      PROBLEM
2	      UNKNOWN
*/
///////////////////////////////////////////////////////////////////////////////
/*
Status
Value	  Type
0	      Trigger is active
1	      Trigger is disabled
*/
///////////////////////////////////////////////////////////////////////////////
/*
Priority
Value	  Type
0	      Not classified
1	      Information
2	      Warning
3	      Average
4	      High
5	      Disaster
*/
///////////////////////////////////////////////////////////////////////////////
/*
Type
Value	  Type
0	      Normal event generation
1	      Generate multiple PROBLEM events
*/
///////////////////////////////////////////////////////////////////////////////
/*Common tasks

The table contains list of common trigger-related tasks and possible implementation using Zabbix API

Task	                                   HOWTO
Add an trigger	                         Use method trigger.create
Add a bunch of new triggers	             Use method trigger.create with array of Trigger objects
Enable an trigger	                       Use method trigger.update, set “status”:0
Disable an trigger	                     Use method trigger.update, set “status”:1
Retrieve trigger details by Trigger IDs	 Use method trigger.get with parameter triggerids
Retrieve triggers details by Host name	 Use method trigger.get with parameter filter, specify “host”: [”<your host1>”]
*/

typedef enum {
    ZabbixTriggerPriorityNotClassified,
    ZabbixTriggerPriorityInformation,
    ZabbixTriggerPriorityWarning,
    ZabbixTriggerPriorityAverage,
    ZabbixTriggerPriorityHigh,
    ZabbixTriggerPriorityDisaster
} ZabbixTriggerPriority;

@interface ZabbixTrigger : NSObject

@property(nonatomic, strong) NSString *triggerid; // ID of the trigger.
@property(nonatomic, strong) NSString *triggerDescription; // (required) Name of the trigger.
@property(nonatomic, assign) NSInteger priority; // Severity of the trigger.
@property(nonatomic, assign) NSInteger value; // Whether the trigger is in OK or problem state.
@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSString *comments;
@property(nonatomic, strong) NSArray *hosts; //"selectHosts":["hostid","host"]

+ (NSString *)triggerPriorityString:(ZabbixTriggerPriority)priority;

+ (UIColor *)triggerPriorityColor:(ZabbixTriggerPriority)priority;

@end
