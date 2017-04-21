//
//  ZabbixGraph.h
//  Shtirlits
//
//  Created by Artem Bartle on 12/14/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GraphViewRangeOneHour = 0,
    GraphViewRangeTwoHours,
    GraphViewRangeThreeHours,
    GraphViewRangeSixHours,
    GraphViewRangeTwelveHours,
    GraphViewRangeOneDay,
    GraphViewRangeSevenDays,
    GraphViewRangeFourteenDays,
    GraphViewRangeOneMonth,
    GraphViewRangeTwoMonths,
    GraphViewRangeThreeMonths,
    GraphViewRangeSixMonths,
    GraphViewRangeOneYear,
    GraphViewRangeCount
} GraphViewRange;

@interface ZabbixGraph : NSObject <NSCoding>

@property(nonatomic, strong) NSString *graphId;
@property(nonatomic, strong) NSString *graphName;
@property(nonatomic, assign) GraphViewRange range;

- (NSString *)stringValueForRange:(GraphViewRange)range;

@end
