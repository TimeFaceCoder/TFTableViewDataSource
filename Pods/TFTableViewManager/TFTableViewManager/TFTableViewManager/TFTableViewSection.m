//
//  TFTableViewSection.m
//  TFTableViewManagerDemo
//
//  Created by Summer on 16/8/24.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "TFTableViewSection.h"
#import "TFTableViewItem.h"
#import "TFTableViewManager.h"

@interface TFTableViewSection ()

@property (strong, readwrite, nonatomic) NSMutableArray *mutableItems;// An mutable array of section items (rows).

@end

@implementation TFTableViewSection

#pragma mark - Properties.
- (NSArray *)items {
    return self.mutableItems;
}

- (NSUInteger)index
{
    TFTableViewManager *tableViewManager = self.tableViewManager;
    return [tableViewManager.sections indexOfObject:self];
}

#pragma mark - Creating and Initializing a TFTableViewSection.

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mutableItems = [NSMutableArray array];
        _headerHeight = 0.0;
        _footerHeight = 0.0;
        _sectionIndex = -1;
    }
    return self;
}

- (instancetype)initWithHeaderTitle:(NSString *)headerTitle {
    return [self initWithHeaderTitle:headerTitle footerTitle:nil];
}

- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle {
    self = [self init];
    if (self) {
        self.headerTitle = headerTitle;
        self.footerTitle = footerTitle;
    }
    return self;
}

- (instancetype)initWithHeaderView:(UIView *)headerView {
    self = [self init];
    if (self) {
        self.headerView = headerView;
    }
    return self;
}

- (instancetype)initWithHeaderView:(UIView *)headerView footerView:(UIView *)footerView {
    self = [self init];
    if (self) {
        self.headerView  = headerView;
        self.footerView  = footerView;
    }
    return self;
}

+ (instancetype)section {
    return [[self alloc] init];
}

+ (instancetype)sectionWithHeaderTitle:(NSString *)headerTitle {
    return [[self alloc] initWithHeaderTitle:headerTitle];
}

+ (instancetype)sectionWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle {
    return [[self alloc] initWithHeaderTitle:headerTitle footerTitle:footerTitle];
}

+ (instancetype)sectionWithHeaderView:(UIView *)headerView {
    return [[self alloc] initWithHeaderView:headerView];
}

+ (instancetype)sectionWithHeaderView:(UIView *)headerView footerView:(UIView *)footerView {
    return [[self alloc] initWithHeaderView:headerView footerView:footerView];
}

#pragma mark - Add and insert Items.

- (void)addItem:(id)item {
    ((TFTableViewItem *)item).section = self;
    [self.mutableItems addObject:item];
}

- (void)addItemsFromArray:(NSArray *)array {
    for (TFTableViewItem *item in array) {
        [self addItem:item];
    }
}

- (void)insertItem:(id)item atIndex:(NSUInteger)index {
    ((TFTableViewItem *)item).section = self;
    [self.mutableItems insertObject:item atIndex:index];
}

- (void)insertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes {
    for (TFTableViewItem *item in items) {
        ((TFTableViewItem *)item).section = self;
    }
    [self.mutableItems insertObjects:items atIndexes:indexes];
}

#pragma mark - Removing Items.

- (void)removeItem:(id)item {
    [self.mutableItems removeObject:item];
}

- (void)removeLastItem {
    [self.mutableItems removeLastObject];
}

- (void)removeItemAtIndex:(NSUInteger)index {
    [self.mutableItems removeObjectAtIndex:index];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes {
    [self.mutableItems removeObjectsAtIndexes:indexes];
}

- (void)removeItemsInArray:(NSArray *)array {
    [self.mutableItems removeObjectsInArray:array];
}

- (void)removeItemsInRange:(NSRange)range {
    [self.mutableItems removeObjectsInRange:range];
}

- (void)removeItem:(id)item inRange:(NSRange)range {
    [self.mutableItems removeObject:item inRange:range];
}

- (void)removeAllItems {
    [self.mutableItems removeAllObjects];
}

#pragma mark - Replacing Items
- (void)replaceItemAtIndex:(NSUInteger)index withItem:(id)item {
    ((TFTableViewItem *)item).section = self;
    [self.mutableItems replaceObjectAtIndex:index withObject:item];
}

- (void)replaceItemsWithItemsFromArray:(NSArray *)array {
    [self removeAllItems];
    [self addItemsFromArray:array];
}

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)items {
    for (TFTableViewItem *item in items) {
        ((TFTableViewItem *)item).section = self;
    }
    [self.mutableItems replaceObjectsAtIndexes:indexes withObjects:items];
}

- (void)replaceItemsInRange:(NSRange)range withItemsFromArray:(NSArray *)array {
    for (TFTableViewItem *item in array) {
        ((TFTableViewItem *)item).section = self;
    }
    [self.mutableItems replaceObjectsInRange:range withObjectsFromArray:array];
}

- (void)exchangeItemAtIndex:(NSUInteger)idx1 withItemAtIndex:(NSUInteger)idx2 {
    [self.mutableItems exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)sortItemsUsingFunction:(NSInteger (*)(__strong id, __strong id, void *))compare context:(void *)context {
    [self.mutableItems sortUsingFunction:compare context:context];
}

- (void)sortItemsUsingSelector:(SEL)comparator {
    [self.mutableItems sortUsingSelector:comparator];
}

#pragma mark - TFTableViewSection handle tableView section actions.

- (void)reloadSectionWithAnimation:(UITableViewRowAnimation)animation {
    [self.tableViewManager.tableView beginUpdates];
    [self.tableViewManager.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.index] withRowAnimation:animation];
    [self.tableViewManager.tableView endUpdates];
}

- (void)deleteSectionWithAnimation:(UITableViewRowAnimation)animation {
    NSInteger index = self.index;
    [self.tableViewManager removeSectionAtIndex:index];
    [self.tableViewManager.tableView beginUpdates];
    [self.tableViewManager.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:animation];
    [self.tableViewManager.tableView endUpdates];
}

- (void)reloadRowsAtIndexes:(NSIndexSet *)indexSet withAnimation:(UITableViewRowAnimation)animation{
    [self.tableViewManager.tableView beginUpdates];
    [self.tableViewManager.tableView reloadRowsAtIndexPaths:[self indexPathsWithIndexSet:indexSet] withRowAnimation:animation];
    [self.tableViewManager.tableView endUpdates];
}

- (void)insertRows:(NSArray<TFTableViewItem *> *)rows atIndexes:(NSIndexSet *)indexSet withRowAnimation:(UITableViewRowAnimation)animation {
    [self insertItems:rows atIndexes:indexSet];
    [self.tableViewManager.tableView beginUpdates];
    [self.tableViewManager.tableView insertRowsAtIndexPaths:[self indexPathsWithIndexSet:indexSet] withRowAnimation:animation];
    [self.tableViewManager.tableView endUpdates];
}

- (void)deleteRowsAtIndexes:(NSIndexSet *)indexSet withAnimation:(UITableViewRowAnimation)animation {
    [self removeItemsAtIndexes:indexSet];
    [self.tableViewManager.tableView beginUpdates];
    [self.tableViewManager.tableView deleteRowsAtIndexPaths:[self indexPathsWithIndexSet:indexSet] withRowAnimation:animation];
    [self.tableViewManager.tableView endUpdates];
}

- (NSArray *)indexPathsWithIndexSet:(NSIndexSet *)indexSet {
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSInteger section = self.index;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
    }];
    return [NSArray arrayWithArray:indexPaths];
}

@end
