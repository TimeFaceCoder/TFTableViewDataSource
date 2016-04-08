//
//  TFTableViewDataManagerProtocol.h
//  TFTableViewDataSource
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#ifndef TFTableViewDataManagerProtocol_h
#define TFTableViewDataManagerProtocol_h

#import "TFTableViewDataSource.h"
#import <TFNetwork/TFNetwork.h>

@class TFTableViewItem;
@class MYTableViewSection;
typedef void (^Completion)(void);
typedef void (^CellViewClickHandler)(__kindof TFTableViewItem *item ,NSInteger actionType);
typedef void (^DeletionHandlerWithCompletion)(__kindof TFTableViewItem *item, void (^)(void));
typedef void (^TableViewReloadCompletionBlock)(BOOL finished,id object,NSError *error,MYTableViewSection *section);


@protocol TFTableViewDataManagerProtocol <NSObject>

@required
/**
 *  列表业务类初始化
 *
 *  @param tableViewDataSource 列表数据源
 *  @param listType            列表类型
 *
 *  @return TFTableDataSourceManager
 */
- (instancetype)initWithDataSource:(TFTableViewDataSource *)tableViewDataSource
                          listType:(NSInteger)listType;

/**
 *  显示列表数据
 *
 *  @param result          数据字典
 *  @param completionBlock 回调block
 */
- (void)reloadView:(NSDictionary *)result block:(TableViewReloadCompletionBlock)completionBlock;
/**
 *  列表内View事件处理
 *
 *  @param item
 *  @param actionType
 */
- (void)cellViewClickHandler:(TFTableViewItem *)item actionType:(NSInteger)actionType;
/**
 *  列表删除事件处理
 *
 *  @param item
 */
- (void)deleteHanlder:(TFTableViewItem *)item completion:(void (^)(void))completion;

/**
 *  刷新指定Cell
 *
 *  @param actionType
 *  @param dataId
 */
- (void)refreshCell:(NSInteger)actionType identifier:(NSString *)identifier;

@end

#endif /* TFTableViewDataManagerProtocol_h */
