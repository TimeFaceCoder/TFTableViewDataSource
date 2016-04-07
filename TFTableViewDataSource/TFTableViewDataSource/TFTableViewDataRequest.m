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
        _params = params;
    }
    return self;
}

- (NSString *)requestUrl {
    return _requestURL;
}

- (id)requestArgument {
    return _params;
}

- (TFRequestMethod)requestMethod {
    return TFRequestMethodGet;
}

- (TFRequestSerializerType)requestSerializerType {
    return TFRequestSerializerTypeJSON;
}
@end
