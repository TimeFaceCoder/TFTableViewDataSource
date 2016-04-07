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
 *  是否当前的数据从缓存获得
 *
 *  @return BOOL
 */
- (BOOL)isDataFromCache;

/**
 *  返回是否当前缓存需要更新
 *
 *  @return BOOL
 */
- (BOOL)isCacheVersionExpired;

/**
 *  强制更新缓存
 */
- (void)startWithoutCache;

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

@end
