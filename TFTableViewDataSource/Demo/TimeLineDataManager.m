//
//  TimeLineDataManager.m
//  TFTableViewDataSource
//
//  Created by Melvin on 4/6/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TimeLineDataManager.h"
#import "TimeLineTableViewItem.h"

@implementation TimeLineDataManager

- (void)reloadView:(NSDictionary *)result block:(TableViewReloadCompletionBlock)completionBlock {
    __weak __typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSArray *dataList = [result objectForKey:@"dataList"];
            MYTableViewSection *section = [MYTableViewSection section];
            for (NSDictionary *entry in dataList) {
                [section addItem:[TimeLineTableViewItem itemWithModel:entry
                                                         clickHandler:weakSelf.cellViewClickHandler]];
            }
            completionBlock(YES,nil,nil,section);
        }
    });
}

@end
