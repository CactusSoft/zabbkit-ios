//
//  DataSizeFormat.h
//  Zabbkit
//
//  Created by Alexey Dozortsev on 23.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSizeFormat : NSObject

+ (void)formatBitsPerSecond:(double)value resultValue:(double*)result units:(NSString**)units;
+ (void)formatBytesPerSecond:(double)value resultValue:(double*)result units:(NSString**)units;
+ (void)formatBytes:(double)value resultValue:(double*)result units:(NSString**)units;
+ (void)formatUpTime:(double)value resultValue:(double*)result units:(NSString**)units;
+ (void)formatUnixTime:(double)value resultValue:(NSString**)units;

@end
