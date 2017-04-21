//
//  NSString+AdditionsMethods.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 22.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AdditionsMethods)
+ (BOOL)isStringWithoutWhitespaces:(NSString *)string;

+ (BOOL)isString:(NSString *)theString
  containsString:(NSString *)subString;

+ (NSString *)stringDateFromTimeStamp:(double)timestamp
                       withDateFormat:(NSString *)dateFormatString;

+ (CGFloat)textHeightForFontName:(NSString *)fontName size:(CGFloat)size width:(CGFloat)width string:(NSString *)string;

+ (NSString *)stringTimeFormatted:(double)totalSeconds;

+ (NSString *)stringTimeFormattedShort:(double)totalSeconds;

@end
