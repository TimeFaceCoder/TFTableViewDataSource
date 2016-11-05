//
//  TFBatchRequest.h
//  TFNetwork
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFRequest.h"

@class TFBatchRequest;
@protocol TFBatchRequestDelegate <NSObject>

@optional

- (void)batchRequestFinished:(TFBatchRequest *)batchRequest;

- (void)batchRequestFailed:(TFBatchRequest *)batchRequest;

@end

@interface TFBatchRequest : NSObject

@property (strong, nonatomic, readonly) NSArray *requestArray;

@property (weak, nonatomic) id<TFBatchRequestDelegate> delegate;

@property (nonatomic, copy) void (^successCompletionBlock)(TFBatchRequest *);

@property (nonatomic, copy) void (^failureCompletionBlock)(TFBatchRequest *);

@property (nonatomic) NSInteger tag;

@property (nonatomic, strong) NSMutableArray *requestAccessories;

- (id)initWithRequestArray:(NSArray *)requestArray;

- (void)start;

- (void)stop;

/// block回调
- (void)startWithCompletionBlockWithSuccess:(void (^)(TFBatchRequest *batchRequest))success
                                    failure:(void (^)(TFBatchRequest *batchRequest))failure;

- (void)setCompletionBlockWithSuccess:(void (^)(TFBatchRequest *batchRequest))success
                              failure:(void (^)(TFBatchRequest *batchRequest))failure;

/**
 *  把block置nil来打破循环引用
 */
- (void)clearCompletionBlock;

/**
 *  Request Accessory，可以hook Request的start和stop
 *
 *  @param accessory
 */
- (void)addAccessory:(id<TFRequestAccessory>)accessory;

/**
 *  是否当前的数据从缓存获得
 *
 *  @return
 */
- (BOOL)isDataFromCache;

@end
