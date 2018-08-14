//
//  TFRequest.h
//  TFNetwork
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFBaseRequest.h"
#import "TFRequestProtocol.h"
@interface TFRequest : TFBaseRequest<TFRequestProtocol>

@property (nonatomic) BOOL ignoreCache;

/**
 *  返回当前缓存的对象
 */
- (id)cacheResponseObject;

/**
 *  返回是否当前缓存需要更新
 *
 *  @return BOOL
 */
- (BOOL)isCacheVersionExpired;

/**
 是否先从缓存中获取

 @return BOOL
 */
- (BOOL)isFirstLoadFromCache;

/**
 从缓存中读取数据之后，是否立马请求新的数据

 @return BOOL
 */
- (BOOL)isFirstLoadFromCacheRequestDataImmediately;

/**
 *  强制更新缓存
 */
- (void)startWithoutCache;

/**
 更新数据不经过缓存

 @param success 成功处理块
 @param failure 失败处理块
 */
- (void)startWithoutCacheCompletionBlockWithSuccess:(TFRequestCompletionBlock)success failure:(TFRequestCompletionBlock)failure;

/**
 *  手动将其他请求的responseObject写入该请求的缓存
 *
 *  @param responseObject
 */
- (void)saveResponseObjectToCacheFile:(id)responseObject;

/// For subclass to overwrite

- (NSInteger)cacheTimeInSeconds;
- (long long)cacheVersion;
- (id)cacheSensitiveData;

/**
 数据是否从缓存中获取而来
 */
@property (nonatomic, assign) BOOL isDataFromCache;

/**
 是否已经从缓存中加载数据
 */
@property (nonatomic, assign) BOOL hasLoadedDataFromCache;

@end
