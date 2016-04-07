//
//  TFNetworkAgent.m
//  TFNetwork
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFNetworkAgent.h"
#import "TFNetworkConfig.h"
#import "TFNetworkPrivate.h"
#import <MPMessagePack/MPMessagePack.h>
#import "NSData+TFNGZIP.h"

@implementation TFNetworkAgent {
    
    AFHTTPSessionManager *_manager;
    TFNetworkConfig *_config;
    NSMutableDictionary *_requestsRecord;
}

+ (TFNetworkAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _config = [TFNetworkConfig sharedInstance];
        _manager = [AFHTTPSessionManager manager];
        _requestsRecord = [NSMutableDictionary dictionary];
        _manager.operationQueue.maxConcurrentOperationCount = 4;
        _manager.securityPolicy = _config.securityPolicy;
    }
    return self;
}

- (NSString *)buildRequestUrl:(TFBaseRequest *)request {
    NSString *detailUrl = [request requestUrl];
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    // filter url
    NSArray *filters = [_config urlFilters];
    for (id<TFUrlFilterProtocol> f in filters) {
        detailUrl = [f filterUrl:detailUrl withRequest:request];
    }
    
    NSString *baseUrl;
    if ([request useCDN]) {
        if ([request cdnUrl].length > 0) {
            baseUrl = [request cdnUrl];
        } else {
            baseUrl = [_config cdnUrl];
        }
    } else {
        if ([request baseUrl].length > 0) {
            baseUrl = [request baseUrl];
        } else {
            baseUrl = [_config baseUrl];
        }
    }
    return [NSString stringWithFormat:@"%@%@", baseUrl, detailUrl];
}

- (void)addRequest:(TFBaseRequest *)request {
    TFRequestMethod method = [request requestMethod];
    NSString *url = [self buildRequestUrl:request];
    id param = request.requestArgument;
    AFConstructingBlock constructingBlock = [request constructingBodyBlock];
    
    if (request.requestSerializerType == TFRequestSerializerTypeHTTP) {
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    } else if (request.requestSerializerType == TFRequestSerializerTypeJSON) {
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    } else if (request.requestSerializerType == TFRequestSerializerTypeMsgPack) {
        
    }
    
    _manager.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    // if api need server username and password
    NSArray *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [_manager.requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString *)authorizationHeaderFieldArray.firstObject
                                                                   password:(NSString *)authorizationHeaderFieldArray.lastObject];
    }
    
    // if api need add custom value to HTTPHeaderField
    NSDictionary *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [_manager.requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                TFNLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    
    // request.requestOperation 部分功能缺失
    if (method == TFRequestMethodGet) {
        request.sessionDataTask = [_manager GET:url
                                     parameters:param
                                       progress:NULL
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                            [self handleRequestResult:task responseObject:responseObject error:nil];
                                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                            [self handleRequestResult:task responseObject:nil error:error];
                                        }];
    } else if (method == TFRequestMethodPost) {
        if (constructingBlock != nil) {
            request.sessionDataTask = [_manager POST:url
                                          parameters:param
                           constructingBodyWithBlock:constructingBlock
                                            progress:^(NSProgress * _Nonnull uploadProgress) {
                                                
                                            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                                       {
                                           [self handleRequestResult:task responseObject:responseObject error:nil];
                                       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                                       {
                                           [self handleRequestResult:task responseObject:nil error:error];
                                       }];
        } else {
            request.sessionDataTask = [_manager POST:url
                                          parameters:param
                                            progress:^(NSProgress * _Nonnull uploadProgress) {
                                                
                                            }
                                             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                                       {
                                           [self handleRequestResult:task responseObject:responseObject error:nil];
                                       }
                                             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                                       {
                                           [self handleRequestResult:task responseObject:nil error:error];
                                       }];
        }
    } else if (method == TFRequestMethodHead) {
        request.sessionDataTask = [_manager HEAD:url
                                      parameters:param
                                         success:^(NSURLSessionDataTask * _Nonnull task)
                                   {
                                       [self handleRequestResult:task responseObject:nil error:nil];
                                   }
                                         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                                   {
                                       [self handleRequestResult:task responseObject:nil error:error];
                                   }];
    } else if (method == TFRequestMethodPut) {
        request.sessionDataTask = [_manager PUT:url
                                     parameters:param
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                                   {
                                       [self handleRequestResult:task responseObject:responseObject error:nil];
                                   }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                                   {
                                       [self handleRequestResult:task responseObject:nil error:error];
                                   }];
    } else if (method == TFRequestMethodDelete) {
        request.sessionDataTask = [_manager DELETE:url
                                        parameters:param
                                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                                   {
                                       [self handleRequestResult:task responseObject:responseObject error:nil];
                                   }
                                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                                   {
                                       [self handleRequestResult:task responseObject:nil error:error];
                                   }];
    } else if (method == TFRequestMethodPatch) {
        request.sessionDataTask = [_manager PATCH:url
                                       parameters:param
                                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                                   {
                                       [self handleRequestResult:task responseObject:responseObject error:nil];
                                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                                   {
                                       [self handleRequestResult:task responseObject:nil error:error];
                                   }];
    } else {
        TFNLog(@"Error, unsupport method type");
        return;
    }
    
    
    TFNLog(@"Add request: %@", NSStringFromClass([request class]));
    [self addOperation:request];
}

- (void)cancelRequest:(TFBaseRequest *)request {
    [request.sessionDataTask cancel];
    [self removeOperation:request.sessionDataTask];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        TFBaseRequest *request = copyRecord[key];
        [request stop];
    }
}

- (BOOL)checkResult:(TFBaseRequest *)request {
    BOOL result = [request statusCodeValidator];
    if (!result) {
        return result;
    }
    id validator = [request jsonValidator];
    if (validator != nil) {
        id json = [request responseObject];
        result = [TFNetworkPrivate checkJson:json withValidator:validator];
    }
    return result;
}
#pragma mark - 处理返回结果

- (void)handleRequestResult:(NSURLSessionDataTask *)sessionDataTask
             responseObject:(id)responseObject
                      error:(NSError *)error {
    NSString *key = [self requestHashKey:sessionDataTask];
    TFBaseRequest *request = _requestsRecord[key];
    TFNLog(@"Finished Request: %@", NSStringFromClass([request class]));
    id object = responseObject;
    request.error = error;
    if (request.requestSerializerType == TFRequestSerializerTypeHTTP) {
        //http
        //检测是否需要GZIP解压缩
        NSString *contentEncoding = [[(NSHTTPURLResponse *)sessionDataTask.response allHeaderFields] objectForKey:@"Content-Encoding"];
        if ([contentEncoding containsString:@"gzip"]) {
            //gzip 解压缩
            object = [responseObject tfn_gunzippedData];
        }
    }
    if (request.requestSerializerType == TFRequestSerializerTypeMsgPack) {
        NSError *error = nil;
        //解析msg pack
        request.responseObject = [MPMessagePackReader readData:object error:&error];
        if (error) {
            request.responseObject = responseObject;
        }
    }
    else {
        request.responseObject = object;
    }
    if (request) {
        BOOL succeed = [self checkResult:request];
        if (succeed) {
            [request toggleAccessoriesWillStopCallBack];
            [request requestCompleteFilter];
            if (request.delegate != nil) {
                [request.delegate requestFinished:request];
            }
            if (request.successCompletionBlock) {
                request.successCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        } else {
            TFNLog(@"Request %@ failed, status code = %ld",
                   NSStringFromClass([request class]), (long)request.responseStatusCode);
            [request toggleAccessoriesWillStopCallBack];
            [request requestFailedFilter];
            if (request.delegate != nil) {
                [request.delegate requestFailed:request];
            }
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        }
    }
    [self removeOperation:sessionDataTask];
    [request clearCompletionBlock];
}

- (NSString *)requestHashKey:(NSURLSessionDataTask *)sessionDataTask {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[sessionDataTask hash]];
    return key;
}

- (void)addOperation:(TFBaseRequest *)request {
    if (request.sessionDataTask != nil) {
        NSString *key = [self requestHashKey:request.sessionDataTask];
        @synchronized(self) {
            _requestsRecord[key] = request;
        }
    }
}

- (void)removeOperation:(NSURLSessionDataTask *)sessionDataTask {
    NSString *key = [self requestHashKey:sessionDataTask];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
    }
    TFNLog(@"Request queue size = %lu", (unsigned long)[_requestsRecord count]);
}

@end
