//
//  TFLoadingTableViewItemCellNode.h
//  TFTableViewDataSource
//
//  Created by Summer on 16/9/9.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import <TFTableViewManager/TFTableViewItemCellNode.h>
#import "TFLoadingTableViewItem.h"

@interface TFLoadingTableViewItemCellNode : TFTableViewItemCellNode

/** @brief load item. */
@property (nonatomic, strong) TFLoadingTableViewItem *tableViewItem;

@end
