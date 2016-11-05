//
//  TFChainRequestAgent.h
//  TFNetwork
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFChainRequest.h"

@interface TFChainRequestAgent : NSObject

+ (TFChainRequestAgent *)sharedInstance;

- (void)addChainRequest:(TFChainRequest *)request;

- (void)removeChainRequest:(TFChainRequest *)request;

@end
