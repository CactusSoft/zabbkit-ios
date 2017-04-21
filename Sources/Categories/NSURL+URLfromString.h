//
//  NSURL+URLfromString.h
//  Shtirlits
//
//  Created by Andrey Kosykhin on 16.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (URLfromString)

+ (NSURL *)detectURLFromString:(NSString *)string;

+ (NSURL *)URLWithValidSchemaFromURL:(NSURL *)anURL;

+ (NSURL *)URLWithPossibleURLString:(NSString *)string;

+ (NSString *)hostFromString:(NSString *)string;

- (NSString *)cleanPath;

@end
