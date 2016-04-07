//
//  MYTableViewSection.m
//  MYTableViewManager
//
//  Created by Melvin on 12/15/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "MYTableViewSection.h"
#import "MYTableViewManager.h"
#import "MYTableViewItem.h"
#import <float.h>

CGFloat const MYTableViewSectionHeaderHeightAutomatic = DBL_MAX;
CGFloat const MYTableViewSectionFooterHeightAutomatic = DBL_MAX;

@interface MYTableViewSection ()

@property (nonatomic ,strong) NSMutableArray *mutableItems;

@end

@implementation MYTableViewSection

+ (instancetype)section
{
    return [[self alloc] init];
}

+ (instancetype)sectionWithHeaderView:(UIView *)headerView
{
    return [[self alloc] initWithHeaderView:headerView footerView:nil];
}

+ (instancetype)sectionWithHeaderView:(UIView *)headerView footerView:(UIView *)footerView
{
    return [[self alloc] initWithHeaderView:headerView footerView:footerView];
}

- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _mutableItems = [[NSMutableArray alloc] init];
    _cellTitlePadding = 5;
    
    return self;
}

- (id)initWithHeaderView:(UIView *)headerView
{
    return [self initWithHeaderView:headerView footerView:nil];
}

- (id)initWithHeaderView:(UIView *)headerView footerView:(UIView *)footerView
{
    self = [self init];
    if (!self)
        return nil;
    
    self.headerView = headerView;
    self.footerView = footerView;
    
    return self;
}


#pragma mark -
#pragma mark Reading information

- (NSUInteger)index
{
    MYTableViewManager *tableViewManager = self.tableViewManager;
    return [tableViewManager.sections indexOfObject:self];
}

#pragma mark -
#pragma mark Managing items

- (NSArray *)items
{
    return self.mutableItems;
}

- (void)addItem:(id)item
{
    if ([item isKindOfClass:[MYTableViewItem class]])
        ((MYTableViewItem *)item).section = self;
    
    [self.mutableItems addObject:item];
}

- (void)addItemsFromArray:(NSArray *)array
{
    for (MYTableViewItem *item in array)
        if ([item isKindOfClass:[MYTableViewItem class]])
            ((MYTableViewItem *)item).section = self;
    
    [self.mutableItems addObjectsFromArray:array];
}

- (void)insertItem:(id)item atIndex:(NSUInteger)index
{
    if ([item isKindOfClass:[MYTableViewItem class]])
        ((MYTableViewItem *)item).section = self;
    
    [self.mutableItems insertObject:item atIndex:index];
}

- (void)insertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes
{
    for (MYTableViewItem *item in items)
        if ([item isKindOfClass:[MYTableViewItem class]])
            ((MYTableViewItem *)item).section = self;
    
    [self.mutableItems insertObjects:items atIndexes:indexes];
}

- (void)removeItem:(id)item inRange:(NSRange)range
{
    [self.mutableItems removeObject:item inRange:range];
}

- (void)removeLastItem
{
    [self.mutableItems removeLastObject];
}

- (void)removeItemAtIndex:(NSUInteger)index
{
    [self.mutableItems removeObjectAtIndex:index];
}

- (void)removeItem:(id)item
{
    [self.mutableItems removeObject:item];
}

- (void)removeAllItems
{
    [self.mutableItems removeAllObjects];
}

- (void)removeItemIdenticalTo:(id)item inRange:(NSRange)range
{
    [self.mutableItems removeObjectIdenticalTo:item inRange:range];
}

- (void)removeItemIdenticalTo:(id)item
{
    [self.mutableItems removeObjectIdenticalTo:item];
}

- (void)removeItemsInArray:(NSArray *)otherArray
{
    [self.mutableItems removeObjectsInArray:otherArray];
}

- (void)removeItemsInRange:(NSRange)range
{
    [self.mutableItems removeObjectsInRange:range];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes
{
    [self.mutableItems removeObjectsAtIndexes:indexes];
}

- (void)replaceItemAtIndex:(NSUInteger)index withItem:(id)item
{
    if ([item isKindOfClass:[MYTableViewItem class]])
        ((MYTableViewItem *)item).section = self;
    
    [self.mutableItems replaceObjectAtIndex:index withObject:item];
}

- (void)replaceItemsWithItemsFromArray:(NSArray *)otherArray
{
    [self removeAllItems];
    [self addItemsFromArray:otherArray];
}

- (void)replaceItemsInRange:(NSRange)range withItemsFromArray:(NSArray *)otherArray range:(NSRange)otherRange
{
    for (MYTableViewItem *item in otherArray)
        if ([item isKindOfClass:[MYTableViewItem class]])
            ((MYTableViewItem *)item).section = self;
    
    [self.mutableItems replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange];
}

- (void)replaceItemsInRange:(NSRange)range withItemsFromArray:(NSArray *)otherArray
{
    for (MYTableViewItem *item in otherArray)
        if ([item isKindOfClass:[MYTableViewItem class]])
            ((MYTableViewItem *)item).section = self;
    
    [self.mutableItems replaceObjectsInRange:range withObjectsFromArray:otherArray];
}

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)items
{
    for (MYTableViewItem *item in items)
        if ([item isKindOfClass:[MYTableViewItem class]])
            ((MYTableViewItem *)item).section = self;
    
    [self.mutableItems replaceObjectsAtIndexes:indexes withObjects:items];
}

- (void)exchangeItemAtIndex:(NSUInteger)idx1 withItemAtIndex:(NSUInteger)idx2
{
    [self.mutableItems exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)sortItemsUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context
{
    [self.mutableItems sortUsingFunction:compare context:context];
}

- (void)sortItemsUsingSelector:(SEL)comparator
{
    [self.mutableItems sortUsingSelector:comparator];
}

#pragma mark -
#pragma mark Manipulating table view section

- (void)reloadSectionWithAnimation:(UITableViewRowAnimation)animation
{
    [self.tableViewManager.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.index] withRowAnimation:animation];
}


@end
