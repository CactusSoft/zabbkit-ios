//
//  NSDate+Util.h
//  RDKit
//
//  Created by Anna Goman on 03.12.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Util)

+ (NSDate*)dateFromString:(NSString*)dateString withFormat:(NSString*)format;
- (NSString*)stringWithFormat:(NSString*)format;
- (NSString*)stringWithDateFormat:(NSDateFormatterStyle)dateFormat timeFormat:(NSDateFormatterStyle)timeFormat;

- (BOOL)isEqualToDateIgnoringTime:(NSDate*)aDate;
- (BOOL)isSameWeekAsDate:(NSDate *)aDate;

- (NSDate*)dateByAddingDays:(NSInteger)aDays;
- (NSDate*)dateBySubtractingDays:(NSInteger)aDays;
- (NSDate*)dateByAddingMonth:(NSInteger)aMonth;
- (NSDate*)dateBySubtractingMonth:(NSInteger)aMonth;
- (NSDate*)dateByAddingYear:(NSInteger)aYear;
- (NSDate*)dateBySubtractingYear:(NSInteger)aYear;

- (NSInteger)daysToDate:(NSDate*)aDate;
- (BOOL)isWorkingDay;
- (NSInteger)numberDaysInMonth;

@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger numberWeekday;

@end
