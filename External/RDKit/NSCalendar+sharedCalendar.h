//
//  NSCalendar+sharedCalendar.h
//  RDKit
//
//  Created by Alexey Dozortsev on 07.12.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar(sharedCalendar)

+ (NSCalendar*)sharedCalendar;
+ (void)resetSharedCalendar;

@end
