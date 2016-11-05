//
//  LoadDataOperation.m
//  TFTableViewDataSource
//
//  Created by zguanyu on 16/9/20.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "LoadDataOperation.h"
#import <TFNetwork/TFBatchRequest.h>
#import "TFTableViewDataRequest.h"

@interface LoadDataOperation ()

@end

@implementation LoadDataOperation
@dynamic finished;
- (id)initWithRequest:(TFBatchRequest *)request dataLoadPolocy:(TFDataLoadPolicy)policy firstLoadOver:(BOOL)firstLoadOver{
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
        _request = request;
        _policy = policy;
        _firstLoadOver = firstLoadOver;
    }
    return self;
}

- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

- (void)main {
    @try {
        
        // Do the main work of the operation here.
        TFTableViewDataRequest *dataRequest = [self.request.requestArray firstObject];
        
        if ([dataRequest cacheResponseObject] && !_firstLoadOver) {
            self.result = dataRequest.responseObject;
            [self completeOperation];
        }
        else {
            [self.request startWithCompletionBlockWithSuccess:^(TFBatchRequest *batchRequest) {
                self.result = dataRequest.responseObject;
                [self completeOperation];
                
            } failure:^(TFBatchRequest *batchRequest) {
                if ([dataRequest cacheResponseObject]) {
                    self.result = dataRequest.responseObject;

                    [self completeOperation];
                }
                else {
                    self.result = dataRequest.responseObject;
                    [self completeOperation];
                }
            }];
        }
    }
    @catch(...) {
        // Do not rethrow exceptions.
    }
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isAsynchronous{
    return YES;
}

@end
