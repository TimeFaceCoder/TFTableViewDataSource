//
//  TFChainRequest.h
//  TFNetwork
//  依赖请求
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFBaseRequest.h"

@class TFChainRequest;
@protocol TFChainRequestDelegate <NSObject>

@optional

- (void)chainRequestFinished:(TFChainRequest *)chainRequest;

- (void)chainRequestFailed:(TFChainRequest *)chainRequest failedBaseRequest:(TFBaseRequest*)request;

@end

typedef void (^ChainCallback)(TFChainRequest *chainRequest, TFBaseRequest *baseRequest);

@interface TFChainRequest : NSObject


@property (weak, nonatomic) id<TFChainRequestDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *requestAccessories;

/// start chain request
- (void)start;

/// stop chain request
- (void)stop;

- (void)addRequest:(TFBaseRequest *)request callback:(ChainCallback)callback;

- (NSArray *)requestArray;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<TFRequestAccessory>)accessory;
@end
