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
            TFTableViewSection *section = [TFTableViewSection section];
            
            for (NSDictionary *entry in dataList) {
                TimeLineTableViewItem *item = [TimeLineTableViewItem itemWithModel:entry cellClickHandler:weakSelf.cellClickHandler];
                item.editingStyle = UITableViewCellEditingStyleDelete;
                [section addItem:item];
            }
            
            NSMutableArray *sections = [NSMutableArray array];
            [sections addObject:section];
            completionBlock(YES,nil,nil,sections);
        }
    });
}

- (void)cellViewClickHandler:(TFTableViewItem *)item actionType:(NSInteger)actionType {
    NSLog(@"%zd", actionType);
}
@end
