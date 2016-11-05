//
//  TFNetworkConfig.h
//  TFNetwork
//  基础配置工具
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFBaseRequest.h"

@protocol TFUrlFilterProtocol <NSObject>
- (NSString *)filterUrl:(NSString *)originUrl withRequest:(TFBaseRequest *)request;
@end

@protocol TFCacheDirPathFilterProtocol <NSObject>
- (NSString *)filterCacheDirPath:(NSString *)originPath withRequest:(TFBaseRequest *)request;
@end

@interface TFNetworkConfig : NSObject

+ (TFNetworkConfig *)sharedInstance;

@property (strong, nonatomic) NSString *baseUrl;
@property (strong, nonatomic) NSString *cdnUrl;
@property (strong, nonatomic) NSDictionary *requestHeaderFieldValueDictionary;
@property (strong, nonatomic, readonly) NSArray *urlFilters;
@property (strong, nonatomic, readonly) NSArray *cacheDirPathFilters;
@property (strong, nonatomic) AFSecurityPolicy *securityPolicy;

- (void)addUrlFilter:(id<TFUrlFilterProtocol>)filter;
- (void)addCacheDirPathFilter:(id <TFCacheDirPathFilterProtocol>)filter;

@end
