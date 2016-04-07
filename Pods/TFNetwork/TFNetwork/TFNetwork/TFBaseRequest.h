//
//  TFBaseRequest.h
//  TFNetwork
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#define UnavailableMacro(msg) __attribute__((unavailable(msg)))

typedef NS_ENUM(NSInteger , TFRequestMethod) {
    TFRequestMethodGet = 0,
    TFRequestMethodPost,
    TFRequestMethodHead,
    TFRequestMethodPut,
    TFRequestMethodDelete,
    TFRequestMethodPatch
};

typedef NS_ENUM(NSInteger , TFRequestSerializerType) {
    TFRequestSerializerTypeHTTP = 0,
    TFRequestSerializerTypeJSON,
    TFRequestSerializerTypeMsgPack
};


/// error code kTFNetworkErrorCode

/**
 *  未知错误
 */
extern NSInteger const kTFNetworkErrorCodeUnknown;
/**
 *  网络异常
 */
extern NSInteger const kTFNetworkErrorCodeHTTP;
/**
 *  接口错误
 */
extern NSInteger const kTFNetworkErrorCodeAPI;

extern NSString *const kTFNetworkErrorDomain;

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

@class TFBaseRequest;

typedef void(^TFRequestCompletionBlock)(__kindof TFBaseRequest *request);

@protocol TFRequestDelegate <NSObject>

@optional

- (void)requestFinished:(TFBaseRequest *)request;
- (void)requestFailed:(TFBaseRequest *)request;
- (void)clearRequest;

@end

@protocol TFRequestAccessory <NSObject>

@optional

- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;

@end

@interface TFBaseRequest : NSObject

/// Tag
@property (nonatomic) NSInteger tag;

/// User info
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, strong) id responseObject;

@property (nonatomic, strong) NSError *error;

/// request delegate object
@property (nonatomic, weak) id<TFRequestDelegate> delegate;

@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;

@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;

@property (nonatomic, readonly) NSInteger responseStatusCode;

@property (nonatomic, copy) TFRequestCompletionBlock successCompletionBlock;

@property (nonatomic, copy) TFRequestCompletionBlock failureCompletionBlock;

@property (nonatomic, strong) NSMutableArray *requestAccessories;

/// append self to request queue
- (void)start;

/// remove self from request queue
- (void)stop;

- (BOOL)isExecuting;

/// block回调
- (void)startWithCompletionBlockWithSuccess:(TFRequestCompletionBlock)success
                                    failure:(TFRequestCompletionBlock)failure;

- (void)setCompletionBlockWithSuccess:(TFRequestCompletionBlock)success
                              failure:(TFRequestCompletionBlock)failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<TFRequestAccessory>)accessory;

/// 以下方法由子类继承来覆盖默认值

/**
 *  请求成功的回调
 */
- (void)requestCompleteFilter;

/**
 *  请求失败的回调
 */
- (void)requestFailedFilter;

/**
 *  请求的URL
 *
 *  @return requestUrl
 */
- (NSString *)requestUrl;
/**
 *  请求的CDNURL
 *
 *  @return cdnUrl
 */
- (NSString *)cdnUrl;

/**
 *  请求的BaseURL
 *
 *  @return baseUrl
 */
- (NSString *)baseUrl;

/**
 *  请求的连接超时时间，默认为60秒
 *
 *  @return NSTimeInterval
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  请求的参数列表
 *
 *  @return requestArgument
 */
- (id)requestArgument;

/**
 *  用于在cache结果，计算cache文件名时，忽略掉一些指定的参数
 *
 *  @param argument
 *
 *  @return
 */
- (id)cacheFileNameFilterForRequestArgument:(id)argument;

/**
 *  Http请求的方法
 *
 *  @return @See TFRequestMethod
 */
- (TFRequestMethod)requestMethod;

/**
 *  请求的SerializerType
 *
 *  @return @See TFRequestSerializerType
 */
- (TFRequestSerializerType)requestSerializerType;

/**
 *  请求的Server用户名和密码
 *
 *  @return
 */
- (NSArray *)requestAuthorizationHeaderFieldArray;

/**
 *  在HTTP报头添加的自定义参数
 *
 *  @return NSDictionary
 */
- (NSDictionary *)requestHeaderFieldValueDictionary;

/**
 *  是否使用CDN的host地址
 *
 *  @return
 */
- (BOOL)useCDN;

/**
 *  用于检查JSON是否合法的对象
 *
 *  @return NSDictionary
 */
- (id)jsonValidator;

/**
 *  用于检查Status Code是否正常的方法
 *
 *  @return
 */
- (BOOL)statusCodeValidator;

/**
 *  当POST的内容带有文件等富文本时使用
 *
 *  @return @See AFConstructingBlock
 */
- (AFConstructingBlock)constructingBodyBlock;

/**
 *  当需要断点续传时，指定续传的地址
 *
 *  @return 
 */
- (NSString *)resumableDownloadPath;


@end
