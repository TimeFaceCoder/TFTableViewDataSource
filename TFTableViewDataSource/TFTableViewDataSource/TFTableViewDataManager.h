//
//  TFTableViewDataManager.h
//  TFTableViewDataSource
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFTableViewDataManagerProtocol.h"
#import "TFTableViewDataSource.h"
#import <TFTableViewItem.h>

@interface TFTableViewDataManager : NSObject<TFTableViewDataManagerProtocol>

/**
 *  @brief the table view datasource.
 */
@property (nonatomic ,weak) TFTableViewDataSource *tableViewDataSource;

/**
 *  @brief the current index path of current handle cell.
 */
@property (nonatomic ,strong) NSIndexPath *currentIndexPath;

/**
 *  @brief 当前列表类型
 */
@property (nonatomic ,assign) NSInteger listType;

/**
 *  @brief cell内的点击动作
 */
@property (nonatomic ,copy) CellClickHandler cellClickHandler;

/**
 *  @brief 删除某个列表
 */
@property (nonatomic ,copy) DeletionHandler deletionHandler;

/**
 *  @brief 清空完成block
 */
- (void)clearCompletionBlock;

@end
