//
//  NSStringPunycodeAdditions.h
//  Punycode
//
//  Created by Wevah on 2005.11.02.
//  Copyright 2005-2012 Derailer. All rights reserved.
//
//  Distributed under an MIT-style license; please
//  see the included LICENSE file for details.
//

#import <Foundation/Foundation.h>


@interface NSString (PunycodeAdditions)

- (NSString *)punycodeEncodedString;
- (NSString *)punycodeDecodedString;

// These methods currently expect self to start with a valid scheme.
- (NSString *)IDNAEncodedString;
- (NSString *)IDNADecodedString;
- (NSString *)encodedURLString;
- (NSString *)decodedURLString;

@end

@interface NSURL (PunycodeAdditions)

+ (NSURL *)URLWithUnicodeString:(NSString *)URLString;
- (NSString *)decodedURLString;

@end
