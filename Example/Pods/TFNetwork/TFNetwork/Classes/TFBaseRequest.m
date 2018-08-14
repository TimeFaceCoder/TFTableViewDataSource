//
//  TFBaseRequest.m
//  TFNetwork
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFBaseRequest.h"
#import "TFNetworkAgent.h"
#import "TFNetworkPrivate.h"

NSInteger const kTFNetworkErrorCodeUnknown = 90000;
NSInteger const kTFNetworkErrorCodeHTTP    = 90001;
NSInteger const kTFNetworkErrorCodeAPI     = 90002;

NSString *const kTFNetworkErrorDomain      = @"cn.timeface.base.network";

@implementation TFBaseRequest

/// for subclasses to overwrite
- (void)requestCompleteFilter {
}

- (void)requestFailedFilter {
}

- (NSString *)requestUrl {
    NSAssert(NO, @"必须重写requestUrl方法并设置该请求所对应url");
    return @"";
}

- (NSString *)cdnUrl {
    return @"";
}

- (NSString *)baseUrl {
    return @"";
}

- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}

- (id)requestArgument {
    return nil;
}

- (id)cacheFileNameFilterForRequestArgument:(id)argument {
    return argument;
}

- (TFRequestMethod)requestMethod {
    return TFRequestMethodGet;
}

- (TFRequestSerializerType)requestSerializerType {
    return TFRequestSerializerTypeHTTP;
}

- (TFResponseSerializerType)responseSerializerType {
    return TFResponseSerializerTypeJSON;
}

- (NSArray *)requestAuthorizationHeaderFieldArray {
    return nil;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

- (NSURLRequest *)buildCustomURLRequest {
    return nil;
}

- (BOOL)useCDN {
    return NO;
}

- (id)jsonValidator {
    return nil;
}

- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <=299) {
        return YES;
    } else {
        return NO;
    }
}

- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

- (NSString *)resumableDownloadPath {
    return nil;
}

/// append self to request queue
- (void)start {
    [self toggleAccessoriesWillStartCallBack];
    [[TFNetworkAgent sharedInstance] addRequest:self];
}

/// remove self from request queue
- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    self.delegate = nil;
    [[TFNetworkAgent sharedInstance] cancelRequest:self];
    [self toggleAccessoriesDidStopCallBack];
}

- (BOOL)isExecuting {
    return self.sessionDataTask.state == NSURLSessionTaskStateRunning;
}

- (void)startWithCompletionBlockWithSuccess:(TFRequestCompletionBlock)success
                                    failure:(TFRequestCompletionBlock)failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(TFRequestCompletionBlock)success
                              failure:(TFRequestCompletionBlock)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse *)self.sessionDataTask.response;
}

- (NSInteger)responseStatusCode {
    return self.response.statusCode;
}

- (NSDictionary *)responseHeaders {
    return self.response.allHeaderFields;
}

#pragma mark - Request Accessoies

- (void)addAccessory:(id<TFRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}

@end
