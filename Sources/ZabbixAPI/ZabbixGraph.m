//
//  ZabbixGraph.m
//  Shtirlits
//
//  Created by Artem Bartle on 12/14/12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "ZabbixGraph.h"

static NSString* kGraphNameKey = @"kGraphNameKey";
static NSString* kGraphIdKey = @"kGraphIdKey";
static NSString* kGraphRangeKey = @"kGraphRangeKey";

@implementation ZabbixGraph

- (id)init
{
    self = [super init];
    if (self) {
        _range = GraphViewRangeOneHour;
    }
    return self;
}

- (BOOL)isEqual:(ZabbixGraph*)graph
{
    return ([_graphId isEqual:graph.graphId] && [_graphName isEqual:graph.graphName] && _range == graph.range);
}


- (NSString *)stringValueForRange:(GraphViewRange)range
{
    switch (range) {
        case GraphViewRangeOneHour:
            return [NSString stringWithFormat:@"1%@",NSLocalizedString(@"hour", nil)];
            break;
        case GraphViewRangeTwoHours:
            return [NSString stringWithFormat:@"2%@",NSLocalizedString(@"hour", nil)];
            break;
        case GraphViewRangeThreeHours:
            return [NSString stringWithFormat:@"3%@",NSLocalizedString(@"hour", nil)];
            break;
        case GraphViewRangeSixHours:
            return [NSString stringWithFormat:@"6%@",NSLocalizedString(@"hour", nil)];
            break;
        case GraphViewRangeTwelveHours:
            return [NSString stringWithFormat:@"12%@",NSLocalizedString(@"hour", nil)];
            break;
        case GraphViewRangeOneDay:
            return [NSString stringWithFormat:@"1%@",NSLocalizedString(@"day", nil)];
            break;
        case GraphViewRangeSevenDays:
            return [NSString stringWithFormat:@"1%@",NSLocalizedString(@"week", nil)];
            break;
        case GraphViewRangeFourteenDays:
            return [NSString stringWithFormat:@"2%@",NSLocalizedString(@"week", nil)];
            break;
        case GraphViewRangeOneMonth:
            return [NSString stringWithFormat:@"1%@",NSLocalizedString(@"month", nil)];
            break;
        case GraphViewRangeTwoMonths:
            return [NSString stringWithFormat:@"2%@",NSLocalizedString(@"month", nil)];
            break;
        case GraphViewRangeThreeMonths:
            return [NSString stringWithFormat:@"3%@",NSLocalizedString(@"month", nil)];
            break;
        case GraphViewRangeSixMonths:
            return [NSString stringWithFormat:@"6%@",NSLocalizedString(@"month", nil)];
            break;
        case GraphViewRangeOneYear:
            return [NSString stringWithFormat:@"1%@",NSLocalizedString(@"year", nil)];
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_graphName forKey:kGraphNameKey];
    [aCoder encodeObject:_graphId forKey:kGraphIdKey];
    [aCoder encodeInteger:_range forKey:kGraphRangeKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        _graphName = [aDecoder decodeObjectForKey:kGraphNameKey];
        _graphId = [aDecoder decodeObjectForKey:kGraphIdKey];
        _range = [aDecoder decodeIntegerForKey:kGraphRangeKey];
    }
    return self;
}

@end
