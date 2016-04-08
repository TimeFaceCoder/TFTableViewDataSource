//
//  TFTableViewItem.m
//  TFTableViewDataSource
//
//  Created by Melvin on 3/30/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFTableViewItem.h"

@implementation TFTableViewItem

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    //
    return self;
}

+ (TFTableViewItem*)itemWithModel:(NSObject *)model
                     clickHandler:(void(^)(TFTableViewItem *item,NSInteger actionType))clickHandler {
    
    TFTableViewItem *item = [[[self class] alloc] init];
    item.model = model;
    item.onViewClickHandler = clickHandler;
    return item;
}

- (void)clearCompletionBlock {
    self.onViewClickHandler = nil;
}

- (void)dealloc {
    [self clearCompletionBlock];
}

@end
