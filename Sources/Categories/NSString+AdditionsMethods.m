//
//  NSString+AdditionsMethods.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 22.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "NSString+AdditionsMethods.h"

@implementation NSString (AdditionsMethods)

+ (BOOL)isStringWithoutWhitespaces:(NSString *)string {
    if (string == nil) {
        return NO;
    }
    NSString *stringWithoutWhitespaces =
            [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (string.length == stringWithoutWhitespaces.length) {
        return YES;
    }
    return NO;
}

+ (BOOL)isString:(NSString *)theString
  containsString:(NSString *)subString {
    NSScanner *scanner = [[NSScanner alloc] initWithString:theString];
    [scanner scanUpToString:subString intoString:nil];
    BOOL consists = [scanner scanLocation] < [theString length];
    return consists;
}

+ (NSString *)stringDateFromTimeStamp:(double)timestamp withDateFormat:(NSString *)dateFormatString
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:dateFormatString];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (CGFloat)textHeightForFontName:(NSString *)fontName size:(CGFloat)size width:(CGFloat)width string:(NSString *)string
{
    CGSize maximumSize = CGSizeMake(width, CGFLOAT_MAX);
    UIFont* font = [UIFont fontWithName:fontName size:size];
    CGSize myStringSize = [string sizeWithFont:font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
    return myStringSize.height;
}

+ (NSString *)stringTimeFormatted:(double)totalSeconds {
// Get the total duration
    NSTimeInterval totalDuration = totalSeconds;

// Create two dates that are totalDuration apart for use
// in creating an NSDateComponents object.
    NSDate *date1 = [NSDate date]; // Now.
    NSDate *date2 = [NSDate dateWithTimeInterval:totalDuration
                                       sinceDate:date1];

// Get the system calendar. If you're positive it will be the
// Gregorian, you could use the specific method for that.
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];

// Specify which date components to get. This will get the hours,
// minutes, and seconds and so on
    NSUInteger unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;

// Create an NSDateComponents object from these dates using the system calendar.
    NSDateComponents *durationComponents = [currentCalendar components:unitFlags
                                                              fromDate:date1
                                                                toDate:date2
                                                               options:0];

    NSMutableArray *intervalComponents = [NSMutableArray array];
    NSInteger components[4];
    NSUInteger componentIndex = 0;

    if ([durationComponents second] || totalSeconds == 0) {
        [intervalComponents addObject:@"%d sec"];
        components[componentIndex++] = [durationComponents second];
    }

    if ([durationComponents minute]) {
        [intervalComponents addObject:@"%d min"];
        components[componentIndex++] = [durationComponents minute];
    }

    if ([durationComponents hour]) {
        if ([durationComponents hour] == 1) {
            [intervalComponents addObject:@"%d hour"];
        } else {
            [intervalComponents addObject:@"%d hours"];
        }
        components[componentIndex++] = [durationComponents hour];
    }

    if ([durationComponents day]) {
        if ([durationComponents day] == 1) {
            [intervalComponents addObject:@"%d day"];
        } else {
            [intervalComponents addObject:@"%d days"];
        }
        components[componentIndex] = [durationComponents day];
    }

    NSString *durationString = [NSString string];

    for (int i = [intervalComponents count] - 1; i >= 0; --i) {
        NSString *compFormat = [intervalComponents objectAtIndex:i];
        if ([intervalComponents count] == 1) {
            durationString = [durationString stringByAppendingFormat:compFormat, components[i]];
        }
        if ([intervalComponents count] > 1 && i == [intervalComponents count] - 1) {

            durationString = [durationString stringByAppendingFormat:compFormat, components[i]];
            durationString = [durationString stringByAppendingFormat:@", "];
        }
        if ([intervalComponents count] > 1 && i == [intervalComponents count] - 2) {
            durationString = [durationString stringByAppendingFormat:compFormat, components[i]];
        }
    }
    return durationString;
}

+ (NSString *)stringTimeFormattedShort:(double)totalSeconds {
    // Get the total duration
    NSTimeInterval totalDuration = totalSeconds;
    
    // Create two dates that are totalDuration apart for use
    // in creating an NSDateComponents object.
    NSDate *date1 = [NSDate date]; // Now.
    NSDate *date2 = [NSDate dateWithTimeInterval:totalDuration
                                       sinceDate:date1];
    
    // Get the system calendar. If you're positive it will be the
    // Gregorian, you could use the specific method for that.
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    
    // Specify which date components to get. This will get the hours,
    // minutes, and seconds and so on
    NSUInteger unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    // Create an NSDateComponents object from these dates using the system calendar.
    NSDateComponents *durationComponents = [currentCalendar components:unitFlags
                                                              fromDate:date1
                                                                toDate:date2
                                                               options:0];
    
    NSMutableArray *intervalComponents = [NSMutableArray array];
    NSInteger components[4];
    NSUInteger componentIndex = 0;
    
    if ([durationComponents second] || totalSeconds == 0) {
        [intervalComponents addObject:@"%ds"];
        components[componentIndex++] = [durationComponents second];
    }
    
    if ([durationComponents minute]) {
        [intervalComponents addObject:@"%dm"];
        components[componentIndex++] = [durationComponents minute];
    }
    
    if ([durationComponents hour]) {
        [intervalComponents addObject:@"%dh"];
        components[componentIndex++] = [durationComponents hour];
    }
    
    if ([durationComponents day]) {
        [intervalComponents addObject:@"%dd"];
        components[componentIndex] = [durationComponents day];
    }
    
    NSString* durationString = [NSString string];
    
    NSInteger index = MAX((NSInteger)[intervalComponents count] - 3, 0);
    for (int i = [intervalComponents count] - 1; i >= index; --i) {
        NSString* compFormat = [intervalComponents objectAtIndex:i];
        durationString = [durationString stringByAppendingFormat:compFormat, components[i]];
        if (i != index) {
            durationString = [durationString stringByAppendingFormat:@" "];
        }
    }
    return durationString;
}

@end
