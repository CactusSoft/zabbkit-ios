//
//  SerializationKeys.h
//  Shtirlits
//
//  Created by Artem Bartle on 12/7/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#ifndef Shtirlits_SerializationKeys_h
#define Shtirlits_SerializationKeys_h

static NSString *const kError = @"error";
static NSString *const kErrorCode = @"code";
static NSString *const kErrorData = @"data";
static NSString *const kErrorMessage = @"message";

static NSString *const kUserId = @"id";
static NSString *const kResult = @"result";

static NSString *const kGroupId = @"groupid";
static NSString *const kGroupName = @"name";

static NSString *const kHostName = @"host";
static NSString *const kHostId = @"hostid";

static NSString *const kEventId = @"eventid";
static NSString *const kEventValue = @"value";
static NSString *const kEventClock = @"clock";
static NSString *const kEventObjectId = @"objectid";

static NSString *const kTriggerId = @"triggerid";
static NSString *const kTriggerDescription = @"description";
static NSString *const kTriggerPriority = @"priority";
static NSString *const kTriggerValue = @"value";
static NSString *const kTriggerHosts = @"hosts";
static NSString *const kTriggerUrl = @"url";
static NSString *const kTriggerComments = @"comments";

static NSString *const kGraphId = @"graphid";
static NSString *const kGraphName = @"name";
static NSString *const kGraphHosts = @"hosts";
static NSString *const kGraphHostName = @"name";

static NSString *const kItemId = @"itemid";
static NSString *const kItemLastValue = @"lastvalue";
static NSString *const kItemValueType = @"value_type";
static NSString *const kItemValueUnits = @"units";
static NSString *const kItemName = @"name";
static NSString *const kItemKey = @"key_";
static NSString *const kItemGraphs = @"graphs";
static NSString *const kItemHosts = @"hosts";

#endif
