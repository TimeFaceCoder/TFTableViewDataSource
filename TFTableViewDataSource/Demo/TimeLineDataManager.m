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

- (void)registeredDataRequest {
    
}

- (void)reloadView:(NSDictionary *)result block:(TableViewReloadCompletionBlock)completionBlock {
    __weak __typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSArray *dataList = [result objectForKey:@"dataList"];
            NSInteger currentCount = [dataList count];
            MYTableViewSection *section = [MYTableViewSection section];
            for (NSDictionary *entry in dataList) {
                [section addItem:[TimeLineTableViewItem itemWithModel:entry
                                                         clickHandler:weakSelf.cellViewClickHandler]];
            }
            [weakSelf updateTableViewData:section];
            completionBlock(YES,nil,nil,currentCount);
        }
    });
}

@end
