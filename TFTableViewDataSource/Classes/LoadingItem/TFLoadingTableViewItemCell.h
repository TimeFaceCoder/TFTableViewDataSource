//
//  TFLoadingTableViewItemCell.h
//  TFTableViewDataSource
//
//  Created by Summer on 16/9/9.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "TFTableViewManagerKit.h"
#import "TFLoadingTableViewItem.h"

@interface TFLoadingTableViewItemCell : TFTableViewItemCell

/** @brief load item. */
@property (nonatomic, strong) TFLoadingTableViewItem *tableViewItem;

@end
