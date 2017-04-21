//
//  NSDate+Util.m
//  RDKit
//
//  Created by Anna Goman on 03.12.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "NSDate+Util.h"
#import "NSCalendar+sharedCalendar.h"

#define kFEDate_DAY_IN_SECONDS  (24*60*60)
#define kFEDate_WEEK_IN_SECONDS (7*24*60*60)

static NSDateFormatter* dateFormatter;

@implementation NSDate (Util)

@dynamic day;
@dynamic month;
@dynamic weekday;
@dynamic numberWeekday;

+ (NSDateFormatter*)dateFormatter
{
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    [dateFormatter setTimeZone:[NSCalendar sharedCalendar].timeZone];
    return dateFormatter;
}

- (NSString*)stringWithFormat:(NSString*)format
{
    NSDateFormatter *currentDateFormatter = [NSDate dateFormatter];
    [currentDateFormatter setDateFormat:format];
    NSString *stringForReturn = [currentDateFormatter stringFromDate:self];
    return stringForReturn;
}

- (NSString*)stringWithDateFormat:(NSDateFormatterStyle)dateFormat timeFormat:(NSDateFormatterStyle)timeFormat
{
    NSDateFormatter *currentDateFormatter = [NSDate dateFormatter];
    [currentDateFormatter setDateStyle:dateFormat];
    [currentDateFormatter setTimeStyle:timeFormat];
    NSString *stringForReturn = [currentDateFormatter stringFromDate:self];
    return stringForReturn;
}

+ (NSDate*)dateFromString:(NSString*)dateString withFormat:(NSString*)format
{
    NSDateFormatter *currentDateFormatter = [NSDate dateFormatter];
    [currentDateFormatter setDateFormat:format];
    NSDate *date = [currentDateFormatter dateFromString:dateString];
    return date;
}

- (BOOL)isEqualToDateIgnoringTime:(NSDate*)aDate
{
    NSDateComponents *components1 = [[NSCalendar sharedCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    NSDateComponents *components2 = [[NSCalendar sharedCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:aDate];
    return (([components1 year] == [components2 year]) && ([components1 month] == [components2 month]) && ([components1 day] == [components2 day]));
}

- (BOOL)isSameWeekAsDate:(NSDate *)aDate
{
    NSDateComponents* components1 = [[NSCalendar sharedCalendar] components:NSWeekCalendarUnit fromDate:self];
    NSDateComponents* components2 = [[NSCalendar sharedCalendar] components:NSWeekCalendarUnit fromDate:aDate];
    return (components1.week == components2.week && fabs([self timeIntervalSinceDate:aDate]) < kFEDate_WEEK_IN_SECONDS);
}

- (NSDate*)dateByAddingDays:(NSInteger)aDays
{
    NSTimeInterval timeInterval = [self timeIntervalSinceReferenceDate] + kFEDate_DAY_IN_SECONDS * aDays;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
}

- (NSDate*)dateBySubtractingDays:(NSInteger)aDays
{
    NSTimeInterval timeInterval = [self timeIntervalSinceReferenceDate] - kFEDate_DAY_IN_SECONDS * aDays;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
}

- (NSDate*)dateByAddingMonth:(NSInteger)aMonth
{
    NSCalendar *calender = [NSCalendar sharedCalendar];
    NSDateComponents *dateComponent = [calender components:NSMonthCalendarUnit fromDate:self];
    [dateComponent setMonth:aMonth];
    return [calender dateByAddingComponents:dateComponent toDate:self options:0];
}

- (NSDate*)dateBySubtractingMonth:(NSInteger)aMonth
{
    NSCalendar *calender = [NSCalendar sharedCalendar];
    NSDateComponents *dateComponent = [calender components:NSMonthCalendarUnit fromDate:self];
    [dateComponent setMonth:-aMonth];
    return [calender dateByAddingComponents:dateComponent toDate:self options:0];
}

- (NSDate*)dateByAddingYear:(NSInteger)aYear
{
    NSCalendar *calender = [NSCalendar sharedCalendar];
    NSDateComponents *dateComponent = [calender components:NSYearCalendarUnit fromDate:self];
    [dateComponent setYear:aYear];
    return [calender dateByAddingComponents:dateComponent toDate:self options:0];
}

- (NSDate*)dateBySubtractingYear:(NSInteger)aYear
{
    NSCalendar *calender = [NSCalendar sharedCalendar];
    NSDateComponents *dateComponent = [calender components:NSYearCalendarUnit fromDate:self];
    [dateComponent setYear:-aYear];
    return [calender dateByAddingComponents:dateComponent toDate:self options:0];
}

- (NSInteger)daysToDate:(NSDate*)aDate
{
    NSTimeInterval timeInterval = [self timeIntervalSinceDate:aDate];
    NSInteger days = timeInterval/kFEDate_DAY_IN_SECONDS;
    NSDate* testDate = [self dateByAddingDays:days];
    if (![testDate isEqualToDateIgnoringTime:aDate]) {
        days++;
    }
    return days;
}

- (BOOL)isWorkingDay
{
    if (self.weekday == 1 || self.weekday == 7) {
        return NO;
    }
    return YES;
}

- (NSInteger)numberDaysInMonth
{
    NSRange dayRange = [[NSCalendar currentCalendar]
                        rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self];
    return dayRange.length;
}

- (NSInteger)day
{
	NSDateComponents *components = [[NSCalendar sharedCalendar] components:NSDayCalendarUnit fromDate:self];
	return [components day];
}

- (NSInteger)week
{
    NSDateComponents* components = [[NSCalendar sharedCalendar] components:NSWeekCalendarUnit fromDate:self];
	return [components week];
}

- (NSInteger)month
{
	NSDateComponents *components = [[NSCalendar sharedCalendar] components:NSMonthCalendarUnit fromDate:self];
	return [components month];
}

- (NSInteger)weekday
{
	NSDateComponents* components = [[NSCalendar sharedCalendar] components:NSWeekdayCalendarUnit fromDate:self];
	return [components weekday];
}

- (NSInteger)numberWeekday
{
	NSDateComponents* components = [[NSCalendar sharedCalendar] components:NSWeekdayCalendarUnit fromDate:self];
	return components.weekday - components.calendar.firstWeekday + 1;
}

@end
