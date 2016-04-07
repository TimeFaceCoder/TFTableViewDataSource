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

@interface TFTableViewDataManager : NSObject<TFTableViewDataManagerProtocol>

@property (nonatomic ,weak) TFTableViewDataSource *tableViewDataSource;
/**
 *  列表内点击事件 block
 */
@property (nonatomic ,copy) CellViewClickHandler   cellViewClickHandler;
/**
 *  列表删除事件 block
 */
@property (nonatomic ,copy) DeletionHandlerWithCompletion deleteHanlder;
@property (nonatomic ,strong) NSIndexPath *currentIndexPath;
@property (nonatomic ,assign) NSInteger listType;

- (void)clearCompletionBlock;
@end
