//
//  NSURL+URLfromString.m
//  Shtirlits
//
//  Created by Andrey Kosykhin on 16.11.12.
//  Copyright (c) 2012 CactusSoft. All rights reserved.
//

#import "NSURL+URLfromString.h"
#import "NSStringPunycodeAdditions.h"

NSString *const matchingUrlPattern = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";


@implementation NSURL (URLfromString)

+ (NSURL *)detectURLFromString:(NSString *)string {
    if (!string)
        return nil;
    NSRegularExpression *linkDetector =
            [NSRegularExpression regularExpressionWithPattern:matchingUrlPattern
                                                      options:0
                                                        error:nil];
    NSRange range = NSMakeRange(0, [string length]);
    NSArray *matches = [linkDetector matchesInString:string
                                             options:0
                                               range:range];
    for (NSTextCheckingResult *match in matches) {
        NSString *urlString = [string substringWithRange:match.range];
        NSURL *url = [NSURL URLWithString:urlString];
        NSLog(@"found URL: %@", url);
        url = [NSURL URLWithValidSchemaFromURL:url];
        return url;
    }
    return nil;
}

+ (NSURL *)URLWithValidSchemaFromURL:(NSURL *)baseURL {
//  ysValidate(baseURL, @"URL");
    NSURL *theURL = [baseURL copy];
    NSString *scheme = [theURL scheme];
    if (scheme == nil) {
        NSString *tmpString = [NSString stringWithFormat:@"http://%@",
                                                         [theURL absoluteString]];
        theURL = [NSURL URLWithString:tmpString];
    }
    return theURL;
}

+ (NSURL *)URLWithPossibleURLString:(NSString *)anyString {
// Try to parse anyString and get valid URL.
//  ysValidate(anyString, @"URL");
    NSURL *anURL = [NSURL URLWithString:[anyString encodedURLString]];
    if (!anURL)
        return nil;
// Get new string from new firstly converted url.
    NSString *urlString = [anURL absoluteString];
    NSURL *returnedURL = [NSURL detectURLFromString:urlString];
    return returnedURL;
}

- (NSString *)cleanPath {
    NSString *urlString = [self absoluteString];
    if (urlString && [urlString length] > 0) {
        urlString = [urlString stringByReplacingOccurrencesOfString:@"http://"
                                                         withString:@""];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"https://"
                                                         withString:@""];
        NSRange range = NSMakeRange([urlString length] - 2, 1);
        urlString =
                [urlString stringByReplacingOccurrencesOfString:@"/"
                                                     withString:@""
                                                        options:NSLiteralSearch
                                                          range:range];
    }
    return urlString;
}

+ (NSString *)hostFromString:(NSString *)string {
    NSString *newString = string;
    if (![string hasPrefix:@"http://"] && ![string hasPrefix:@"https://"]) {
        newString = [NSString stringWithFormat:@"%@%@", @"http://", string];
    }
// Return nil if none found.
    NSString *rootDomain = nil;
// Convert the string to an NSURL to take advantage of NSURL's parsing abilities.
    NSURL *url = [NSURL URLWithString:newString];
// Get the host, e.g.
    NSString *host = [url host];
// Separate the host into its constituent components
    NSArray *hostComponents = [host componentsSeparatedByString:@"/"];
    if ([hostComponents count] > 0) {
        return [NSString stringWithFormat:@"%@", [hostComponents objectAtIndex:0]];
    }
    if ([hostComponents count] >= 2) {
// Create a string out of the last two components in the host name, e.g.
        rootDomain = [NSString stringWithFormat:@"%@", [hostComponents objectAtIndex:([hostComponents count] - 2)]];
    }
    return rootDomain;
}

@end
