//
//  TFTableViewItem.m
//  TFTableViewManagerDemo
//
//  Created by Summer on 16/8/24.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "TFTableViewItem.h"
#import "TFTableViewSection.h"
#import "TFTableViewManager.h"

@implementation TFTableViewItem

#pragma mark - TFTableViewItem Properties.

- (NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:[self.section.items indexOfObject:self] inSection:self.section.index];
}


#pragma mark - Creating and Initializing a TFTableViewItem.

+ (instancetype)item {
    TFTableViewItem *item = [[self alloc] init];
    item.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0);
    return item;
}

+ (instancetype)itemWithModel:(id)model {
    TFTableViewItem *item = [[self alloc] init];
    item.model = model;
    item.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0);
    return item;
}

+ (instancetype)itemWithModel:(id)model selectionHandler:(TFTableViewItemSelectionHandler)selectionHandler {
    TFTableViewItem *item = [[self alloc] init];
    item.model = model;
    item.selectionHandler = selectionHandler;
    item.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0);
    return item;
}

+ (instancetype)itemWithModel:(id)model cellClickHandler:(TFTableViewItemCellClickHandler)cellClickHandler {
    TFTableViewItem *item = [[self alloc] init];
    item.model = model;
    item.cellClickHandler = cellClickHandler;
    item.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0);
    return item;
}

+ (instancetype)itemWithModel:(id)model selectionHandler:(TFTableViewItemSelectionHandler)selectionHandler cellClickHandler:(TFTableViewItemCellClickHandler)cellClickHandler {
    TFTableViewItem *item = [[self alloc] init];
    item.model = model;
    item.selectionHandler = selectionHandler;
    item.cellClickHandler = cellClickHandler;
    item.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0);
    return item;
}

#pragma mark - reload and select table view item

- (void)selectRowAnimated:(BOOL)animated {
    [self selectRowAnimated:animated scrollPosition:UITableViewScrollPositionNone];
}

- (void)selectRowAnimated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    [self.section.tableViewManager.tableView selectRowAtIndexPath:self.indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)deselectRowAnimated:(BOOL)animated
{
    [self.section.tableViewManager.tableView deselectRowAtIndexPath:self.indexPath animated:animated];
}

- (void)reloadRowWithAnimation:(UITableViewRowAnimation)animation
{
    [self.section.tableViewManager.tableView beginUpdates];
    [self.section.tableViewManager.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:animation];
    [self.section.tableViewManager.tableView endUpdates];
}

- (void)deleteRowWithAnimation:(UITableViewRowAnimation)animation
{
    TFTableViewSection *section = self.section;
    NSIndexPath *currentIndexPath = self.indexPath;
    //remove the item in section.
    [section removeItemAtIndex:currentIndexPath.row];
    //remove the cell in tableView.
    [self.section.tableViewManager.tableView beginUpdates];
    [self.section.tableViewManager.tableView deleteRowsAtIndexPaths:@[currentIndexPath] withRowAnimation:animation];
    [self.section.tableViewManager.tableView endUpdates];
}



@end
