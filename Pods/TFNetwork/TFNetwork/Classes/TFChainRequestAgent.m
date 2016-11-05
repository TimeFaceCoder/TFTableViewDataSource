//
//  TFChainRequestAgent.m
//  TFNetwork
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFChainRequestAgent.h"

@interface TFChainRequestAgent()

@property (strong, nonatomic) NSMutableArray *requestArray;

@end

@implementation TFChainRequestAgent

+ (TFChainRequestAgent *)sharedInstance {
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
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addChainRequest:(TFChainRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeChainRequest:(TFChainRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}


@end
