//
//  TFBatchRequestAgent.h
//  TFNetwork
//  批量请求工具
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFBatchRequest.h"

@interface TFBatchRequestAgent : NSObject

+ (TFBatchRequestAgent *)sharedInstance;

- (void)addBatchRequest:(TFBatchRequest *)request;

- (void)removeBatchRequest:(TFBatchRequest *)request;

@end
