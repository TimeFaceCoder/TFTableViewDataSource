//
//  TFTableViewDataRequest.m
//  TFTableViewDataSource
//
//  Created by Melvin on 4/6/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFTableViewDataRequest.h"

@implementation TFTableViewDataRequest {
}

- (instancetype)initWithRequestURL:(NSString *)url params:(NSDictionary *)params {
    self = [super init];
    if (self) {
        _requestURL = url;
        _requestArgument = params;
        _cacheTimeInSeconds = -1;
        _isFirstLoadFromCacheRequestDataImmediately = NO;
        _isFirstLoadFromCache = YES;
    }
    return self;
}

- (NSInteger)cacheTimeInSeconds {
    return _cacheTimeInSeconds;
}

- (BOOL)isFirstLoadFromCache {
    return _isFirstLoadFromCache;
}

- (BOOL)isFirstLoadFromCacheRequestDataImmediately {
    return _isFirstLoadFromCacheRequestDataImmediately;
}

- (NSString *)requestUrl {
    return _requestURL;
}

- (id)requestArgument {
    return _requestArgument;
}

- (TFRequestMethod)requestMethod {
    return TFRequestMethodGet;
}

- (TFRequestSerializerType)requestSerializerType {
    return TFRequestSerializerTypeJSON;
}

@end
