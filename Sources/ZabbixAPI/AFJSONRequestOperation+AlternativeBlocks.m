//
//  AFJSONRequestOperation+AlternativeBlocks.m
//  Zabbkit
//
//  Created by Alexey Dozortsev on 04.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "AFJSONRequestOperation+AlternativeBlocks.h"

@implementation AFJSONRequestOperation (AlternativeBlocks)

+ (instancetype)ZabbKitJSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                               success:(void (^)(AFJSONRequestOperation *operation, id JSON))success
                                               failure:(void (^)(AFJSONRequestOperation *operation, NSError *error, id JSON))failure {
    AFJSONRequestOperation *operation = [(AFJSONRequestOperation *) [self alloc] initWithRequest:urlRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success((AFJSONRequestOperation *) operation, responseObject);
        }
    }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *) operation, error, [(AFJSONRequestOperation *) operation responseJSON]);
        }
    }];
    return operation;
}

@end
