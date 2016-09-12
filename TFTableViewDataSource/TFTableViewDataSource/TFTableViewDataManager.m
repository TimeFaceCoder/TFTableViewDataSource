//
//  TFTableViewDataManager.m
//  TFTableViewDataSource
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFTableViewDataManager.h"

@interface TFTableViewDataManager() {
    
}



@end

@implementation TFTableViewDataManager

- (instancetype)initWithDataSource:(TFTableViewDataSource *)tableViewDataSource
                          listType:(NSInteger)listType {
    self = [super init];
    if (!self) {
        return nil;
    }
    _tableViewDataSource = tableViewDataSource;
    _listType = listType;
    __weak __typeof(self)weakSelf = self;
    _cellClickHandler = ^ (TFTableViewItem *item ,NSInteger actionType) {
        __typeof(&*weakSelf) strongSelf = weakSelf;
        strongSelf.currentIndexPath = item.indexPath;
        if ([strongSelf.tableViewDataSource.delegate respondsToSelector:@selector(actionOnView:actionType:)]) {
            [strongSelf.tableViewDataSource.delegate actionOnView:item actionType:actionType];
        }
        [strongSelf cellViewClickHandler:item actionType:actionType];
    };
    _deletionHandler = ^(TFTableViewItem *item ,NSIndexPath *indexPath) {
        __typeof(&*weakSelf) strongSelf = weakSelf;
        [strongSelf deleteHanlder:item];
    };
    
    return self;
}

/**
 *  显示列表数据
 *
 *  @param result          数据字典
 *  @param completionBlock 回调block
 */
- (void)reloadView:(NSDictionary *)result block:(TableViewReloadCompletionBlock)completionBlock {

}
/**
 *  列表内View事件处理
 *
 *  @param item
 *  @param actionType
 */
- (void)cellViewClickHandler:(TFTableViewItem *)item actionType:(NSInteger)actionType {
    self.currentIndexPath = item.indexPath;
}
/**
 *  列表删除事件处理
 *
 *  @param item
 */
- (void)deleteHanlder:(TFTableViewItem *)item{
    self.currentIndexPath = item.indexPath;
}

/**
 *  刷新指定Cell
 *
 *  @param actionType
 *  @param dataId
 */
- (void)refreshCell:(NSInteger)actionType identifier:(NSString *)identifier {
    
}


- (void)clearCompletionBlock {
    self.cellClickHandler = nil;
    self.deletionHandler = nil;
}

@end
