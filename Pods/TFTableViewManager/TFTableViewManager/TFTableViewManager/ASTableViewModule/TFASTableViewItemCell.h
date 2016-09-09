//
//  PFASTableViewItemCell.h
//  TFTableViewManagerDemo
//
//  Created by Summer on 16/9/5.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@class TFTableViewManager;
@class TFTableViewItem;

@interface TFASTableViewItemCell : ASCellNode

/**
 *  @brief The `TFASTableViewManager` that needs to be managed using this `PFASTableViewItemCell`.
 */
@property (weak, nonatomic) TFTableViewManager *tableViewManager;

/**
 *  @brief the item of the cell.
 */
@property (strong, nonatomic) TFTableViewItem *tableViewItem;

/**
 *  the item of the cell.
 *
 *  @param tableViewItem item.
 *
 *  @return PFASTableViewItemCell.
 */
- (instancetype)initWithTableViewItem:(TFTableViewItem *)tableViewItem;

/**
 *  add sub nodes in this method.
 */
- (void)cellLoadSubNodes;


@end
