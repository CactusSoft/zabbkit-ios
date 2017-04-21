//
//  AFJSONRequestOperation+AlternativeBlocks.h
//  Zabbkit
//
//  Created by Alexey Dozortsev on 04.09.13.
//  Copyright (c) 2013 CactusSoft. All rights reserved.
//

#import "AFJSONRequestOperation.h"

// copy of AFJSONRequestOperation
// json request operation to logging http body

@interface AFJSONRequestOperation (AlternativeBlocks)

+ (instancetype)ZabbKitJSONRequestOperationWithRequest:AFJSONRequestOperationurlRequest
                                               success:(void (^)(AFJSONRequestOperation *operation, id JSON))success
                                               failure:(void (^)(AFJSONRequestOperation *operation, NSError *error, id JSON))failure;

@end
