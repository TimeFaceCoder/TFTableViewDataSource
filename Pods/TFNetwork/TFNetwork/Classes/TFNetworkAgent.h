//
//  TFNetworkAgent.h
//  TFNetwork
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFBaseRequest.h"

@interface TFNetworkAgent : NSObject

+ (TFNetworkAgent *)sharedInstance;

- (void)addRequest:(TFBaseRequest *)request;

- (void)cancelRequest:(TFBaseRequest *)request;

- (void)cancelAllRequests;

/**
 *  根据request和networkConfig构建url
 *
 *  @param request
 *
 *  @return
 */
- (NSString *)buildRequestUrl:(TFBaseRequest *)request;

@end
