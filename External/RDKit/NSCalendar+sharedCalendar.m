//
//  NSCalendar+sharedCalendar.m
//  RDKit
//
//  Created by Alexey Dozortsev on 07.12.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "NSCalendar+sharedCalendar.h"

static NSCalendar* sharedCalendar = nil;

@implementation NSCalendar(sharedCalendar)

+ (NSCalendar*)sharedCalendar
{
    if (sharedCalendar == nil) {
        @synchronized(self) {
            if (sharedCalendar == nil) {
                sharedCalendar = [NSCalendar currentCalendar];
            }
        }
    }
    return sharedCalendar;
}

+ (void)resetSharedCalendar
{
	if (sharedCalendar != nil) {
        @synchronized(self) {
        	sharedCalendar = nil;
        }
    }
}

@end
