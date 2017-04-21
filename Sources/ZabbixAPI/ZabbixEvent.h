//
//  ZabbixEvent.h
//  Shtirlits
//
//  Created by Artem Bartle on 12/7/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 acknowledged	--- Default: 0.
*/
///////////////////////////////////////////////////////////////////////////////
/*
 object
 
 Possible values:
 0 - (default) trigger;
 1 - discovered host;
 2 - discovery service;
 3 - auto-registered host.
 */
///////////////////////////////////////////////////////////////////////////////
/*
source
 Possible values:
 0 - (default) event created by a trigger;
 1 - event created by a discovery rule;
 2 - event created by active agent auto-registration.
 */
///////////////////////////////////////////////////////////////////////////////
/*
 value
 Possible values for trigger events:
 0 - (default) OK;
 1 - problem;
 2 - unknown.
 
 Possible values for discovery events:
 0 - (default) host up;
 1 - host down;
 2 - host discovered;
 3 - host lost.
 
 This parameter is not used for active agent auto-registration events.
 */
///////////////////////////////////////////////////////////////////////////////

@interface ZabbixEvent : NSObject

@property(nonatomic, strong) NSString *eventid;  // ID of the event.
@property(nonatomic, assign) double clock; // Time when the event was created.
@property(nonatomic, strong) NSString *objectid; // ID of the related object.
@property(nonatomic, assign) double duration;
@property(nonatomic, assign) NSInteger value; // State of the related object.

@end
