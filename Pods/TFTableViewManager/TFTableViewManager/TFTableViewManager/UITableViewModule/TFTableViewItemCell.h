//
//  PFUITableViewItemCell.h
//  TFTableViewManagerDemo
//
//  Created by Summer on 16/8/26.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFTableViewManager;
@class TFTableViewItem;

/**
 *  the table view cell when use a table view of table manager.
 */
@interface TFTableViewItemCell : UITableViewCell

///-----------------------------
/// @name Properties.
///-----------------------------

/**
 *  @brief The `TFUITableViewManager` that needs to be managed using this `PFUITableViewItemCell`.
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
- (instancetype)initWithTableViewItem:(TFTableViewItem *)tableViewItem reuseIdentifier:(NSString *)reuseIdentifier;

///-----------------------------
/// @name Handling Cell Events.
///-----------------------------

/**
 *  height for the item
 *
 *  @param item             a TFTableViewItem.
 *  @param tableViewManager handle items.
 *
 *  @return a CGFloat value of cell height.
 */
+ (CGFloat)heightWithItem:(TFTableViewItem *)item tableViewManager:(TFTableViewManager *)tableViewManager;

///-----------------------------
/// @name Cell life cycle.
///-----------------------------

/**
 *  add cell subviews in this method.
 */
- (void)cellLoadSubViews;

/**
 *  cell will appear, deal with the display values of subviews in this method.
 */
- (void)cellWillAppear;

/**
 *  cell did disappear.
 */
- (void)cellDidDisappear;



@end
