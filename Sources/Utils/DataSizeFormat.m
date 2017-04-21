//
//  DataSizeFormat.m
//  Zabbkit
//
//  Created by Alexey Dozortsev on 23.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "DataSizeFormat.h"
#import "NSString+AdditionsMethods.h"
#import "NSDate+Util.h"

static const float kTera = 1024.0f*1024.0f*1024.0f*1024.0f;
static const float kGiga = 1024.0f*1024.0f*1024.0f;
static const float kMega = 1024.0f*1024.0f;
static const float kKilo = 1024.0f;

static const float kDay  = 60.0f*60.0f*24;
static const float kHour = 60.0f*60.0f;
static const float kMin  = 60.0f;

@implementation DataSizeFormat

+ (void)formatBitsPerSecond:(double)value resultValue:(double*)result units:(NSString**)units
{
    if (value > kTera) { //Tbitps
        *units = @"Tbps";
        *result = value / kTera;
    } else if (value > kGiga) { //Gbitps
        *units = @"Gbps";
        *result = value / kGiga;
    } else if (value > kMega) { //Mbitps
        *units = @"Mbps";
        *result = value / kMega;
    } else if (value > kKilo) { //kbitps
        *units = @"kbps";
        *result = value / kKilo;
    } else { // bitps
        *units = @"bps";
        *result = value;
    }
}

+ (void)formatBytesPerSecond:(double)value resultValue:(double*)result units:(NSString**)units
{
    if (value > kTera) { //TByteps
        *units = @"TBps";
        *result = value / kTera;
    } else if (value > kGiga) { //GByteps
        *units = @"GBps";
        *result = value / kGiga;
    } else if (value > kMega) { //MByteps
        *units = @"MBps";
        *result = value / kMega;
    } else if (value > kKilo) { //kByteps
        *units = @"kBps";
        *result = value / kKilo;
    } else { // Byte
        *units = @"Bps";
        *result = value;
    }
}

+ (void)formatBytes:(double)value resultValue:(double*)result units:(NSString**)units
{
    if (value > kTera) { //TByte
        *units = @"TB";
        *result = value / kTera;
    } else if (value > kGiga) { //GByte
        *units = @"GB";
        *result = value / kGiga;
    } else if (value > kMega) { //MByte
        *units = @"MB";
        *result = value / kMega;
    } else if (value > kKilo) { //kByte
        *units = @"kB";
        *result = value / kKilo;
    } else { // Byte
        *units = @"B";
        *result = value;
    }
}

+ (void)formatUpTime:(double)value resultValue:(double*)result units:(NSString**)units
{
    if (value > kDay) {
        *result = value / kDay;
        if (*result >= 2) {
            *units = @"days";
        } else {
            *units = @"day";
        }
    } else if (value > kHour) {
        *result = value / kHour;
        if (*result >= 2) {
            *units = @"hours";
        } else {
            *units = @"hour";
        }
    } else if (value > kMin) {
        *result = value / kMin;
        if (*result >= 2) {
            *units = @"minutes";
        } else {
            *units = @"minute";
        }
    } else {
        *result = value;
        if (*result >= 2) {
            *units = @"seconds";
        } else {
            *units = @"second";
        }
    }
}

+ (void)formatUnixTime:(double)value resultValue:(NSString**)units
{
    *units = [[NSDate dateWithTimeIntervalSince1970:value] stringWithDateFormat:kCFDateFormatterMediumStyle timeFormat:kCFDateFormatterMediumStyle];
}

@end
