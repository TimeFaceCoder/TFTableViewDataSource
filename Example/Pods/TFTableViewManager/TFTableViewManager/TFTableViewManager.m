//
//  TFTableViewManager.m
//  TFTableViewManagerDemo
//
//  Created by Summer on 16/8/24.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "TFTableViewManager.h"
#import "TFTableViewItem.h"
#import "TFTableViewItemCell.h"
#import "TFTableViewItemCellNode.h"

@interface TFTableViewManager ()<UITableViewDataSource,UITableViewDelegate,ASTableDataSource,ASTableDelegate,ASCollectionDelegate,ASCollectionDataSource>

@property (nonatomic, strong) NSMutableArray *mutableSections;

@end

@implementation TFTableViewManager

#pragma mark - Properties.

- (NSArray<TFTableViewSection *> *)sections
{
    return self.mutableSections;
}

- (NSMutableArray *)mutableSections {
    if (!_mutableSections) {
        _mutableSections = [NSMutableArray array];
    }
    return _mutableSections;
}

#pragma mark - Creating and Initializing a TFTableViewManager.

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        tableView.delegate     = self;
        tableView.dataSource   = self;
        self.tableView         = tableView;
        if (@available(iOS 11.0, *)) {
            self.tableView.separatorInsetReference = UITableViewSeparatorInsetFromCellEdges;
        }
    }
    return self;
}

- (instancetype)initWithTableNode:(ASTableNode *)tableNode {
    self = [super init];
    if (self) {
        tableNode.delegate     = self;
        tableNode.dataSource   = self;
        self.tableNode         = tableNode;
        self.tableView         = tableNode.view;
    }
    return self;
}

- (instancetype)initWithCollectionNode:(ASCollectionNode *)collectionNode {
    self = [super init];
    if (self) {
        collectionNode.delegate     = self;
        collectionNode.dataSource   = self;
        self.collectionNode         = collectionNode;
        self.collectionView         = collectionNode.view;
    }
    return self;
}


- (TFTableViewItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    return ((TFTableViewSection *)self.mutableSections[indexPath.section]).items[indexPath.row];
}

#pragma mark Add and insert sections.

- (void)addSection:(TFTableViewSection *)section {
    section.tableViewManager = self;
    [self.mutableSections addObject:section];
}

- (void)addSectionsFromArray:(NSArray<TFTableViewSection *> *)array {
    for (TFTableViewSection *section in array) {
        [self addSection:section];
    }
}

- (void)insertSection:(TFTableViewSection *)section atIndex:(NSUInteger)index {
    section.tableViewManager = self;
    [self.mutableSections insertObject:section atIndex:index];
}

- (void)insertSections:(NSArray<TFTableViewSection *> *)sections atIndexes:(NSIndexSet *)indexes {
    for (TFTableViewSection *section in sections) {
        section.tableViewManager = self;
    }
    [self.mutableSections insertObjects:sections atIndexes:indexes];
}

#pragma mark - Remove Sections

- (void)removeSection:(TFTableViewSection *)section {
    [self.mutableSections removeObject:section];
}

- (void)removeSectionAtIndex:(NSUInteger)index {
    [self.mutableSections removeObjectAtIndex:index];
}

- (void)removeLastSection {
    [self.mutableSections removeLastObject];
}

- (void)removeAllSections {
    [self.mutableSections removeAllObjects];
}

- (void)removeSectionsInArray:(NSArray<TFTableViewSection *> *)array {
    [self.mutableSections removeObjectsInArray:array];
}

- (void)removeSectionsInRange:(NSRange)range {
    [self.mutableSections removeObjectsInRange:range];
}

- (void)removeSection:(TFTableViewSection *)section inRange:(NSRange)range {
    [self.mutableSections removeObject:section inRange:range];
}

- (void)removeSectionsAtIndexes:(NSIndexSet *)indexes {
    [self.mutableSections removeObjectsAtIndexes:indexes];
}

#pragma mark - Replace Sections.

- (void)replaceSectionAtIndex:(NSUInteger)index withSection:(TFTableViewSection *)section {
    section.tableViewManager = self;
    [self.mutableSections replaceObjectAtIndex:index withObject:section];
}

- (void)replaceSectionsWithSectionsFromArray:(NSArray<TFTableViewSection *> *)array {
    [self removeAllSections];
    [self addSectionsFromArray:array];
}

- (void)replaceSectionsAtIndexes:(NSIndexSet *)indexes withSections:(NSArray<TFTableViewSection *> *)sections {
    for (TFTableViewSection *section in sections) {
        section.tableViewManager = self;
    }
    [self.mutableSections replaceObjectsAtIndexes:indexes withObjects:sections];
}

- (void)replaceSectionsInRange:(NSRange)range withSectionsFromArray:(NSArray<TFTableViewSection *> *)array {
    for (TFTableViewSection *section in array) {
        section.tableViewManager = self;
    }
    [self.mutableSections replaceObjectsInRange:range withObjectsFromArray:array];
}

#pragma mark - Rearranging Sections

- (void)exchangeSectionAtIndex:(NSUInteger)idx1 withSectionAtIndex:(NSUInteger)idx2 {
    [self.mutableSections exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)sortSectionsUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context
{
    [self.mutableSections sortUsingFunction:compare context:context];
}

- (void)sortSectionsUsingSelector:(SEL)comparator
{
    [self.mutableSections sortUsingSelector:comparator];
}

#pragma mark - Row and section insertion/deletion/reloading.

- (void)insertSections:(NSArray<TFTableViewSection *> *)sections atIndexes:(NSIndexSet *)indexSet withRowAnimation:(UITableViewRowAnimation)animation {
    [self insertSections:sections atIndexes:indexSet];
    
    if (self.collectionNode) {
        [self.collectionNode beginUpdates];
        [self.collectionNode insertSections:indexSet];
        [self.collectionNode endUpdatesAnimated:YES];
    }
    else {
        [self.tableView beginUpdates];
        [self.tableView insertSections:indexSet withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (void)addSections:(NSArray<TFTableViewSection *> *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.sections.count, sections.count)];
    [self insertSections:sections atIndexes:indexSet withRowAnimation:animation];
}

- (void)deleteSectionsAtIndexSet:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self removeSectionsAtIndexes:sections];
    if (self.collectionNode) {
        [self.collectionNode beginUpdates];
        [self.collectionNode deleteSections:sections];
        [self.collectionNode endUpdatesAnimated:YES];
    }
    else {
        [self.tableView beginUpdates];
        [self.tableView deleteSections:sections withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (void)deleteSections:(NSArray<TFTableViewSection *> *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self deleteSectionsAtIndexSet:[self indexSetWithSections:sections] withRowAnimation:animation];
}

- (NSIndexSet*)indexSetWithSections:(NSArray<TFTableViewSection *> *)sections {
    NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
    for (TFTableViewSection* section in sections) {
        [indexSet addIndex:section.index];
    }
    return [indexSet copy];
}

- (void)reloadSectionsAtIndexSet:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    
    if (self.collectionNode) {
        [self.collectionNode beginUpdates];
        [self.collectionNode reloadSections:sections];
        [self.collectionNode endUpdatesAnimated:YES];
    }
    else {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:sections withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (void)reloadSections:(NSArray<TFTableViewSection *> *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadSectionsAtIndexSet:[self indexSetWithSections:sections] withRowAnimation:animation];
    
}

- (void)reloadAllSectionsWithRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadSections:self.sections withRowAnimation:animation];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self exchangeSectionAtIndex:section withSectionAtIndex:newSection];
    
    if (self.collectionNode) {
        [self.collectionNode beginUpdates];
        [self.collectionNode moveSection:section toSection:newSection];
        [self.collectionNode endUpdatesAnimated:YES];
    }
    else {
        [self.tableView beginUpdates];
        [self.tableView moveSection:section toSection:newSection];
        [self.tableView endUpdates];
    }
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    
    if (self.collectionNode) {
        [self.collectionNode beginUpdates];
        [self.collectionNode reloadSections:indexPaths];
        [self.collectionNode endUpdatesAnimated:YES];
    }
    else {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (void)insertRows:(NSArray<TFTableViewItem *> *)rows atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    NSInteger count = 0;
    for (NSIndexPath *indexPath in indexPaths) {
        TFTableViewSection *section = self.mutableSections[indexPath.section];
        TFTableViewItem *item = rows[count];
        item.section = section;
        [section insertItem:item atIndex:indexPath.row];
        count ++;
    }
    
    if (self.collectionNode) {
        [self.collectionNode beginUpdates];
        [self.collectionNode insertItemsAtIndexPaths:indexPaths];
        [self.collectionNode endUpdatesAnimated:YES];
    }
    else {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    for (NSIndexPath *indexPath in indexPaths) {
        TFTableViewSection *section = self.mutableSections[indexPath.section];
        [section removeItemAtIndex:indexPath.row];
    }
    if (self.collectionNode) {
        [self.collectionNode beginUpdates];
        [self.collectionNode deleteItemsAtIndexPaths:indexPaths];
        [self.collectionNode endUpdatesAnimated:YES];
    }
    else {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    TFTableViewItem *oldItem = [self itemAtIndexPath:indexPath];
    TFTableViewSection *oldSection = self.mutableSections[indexPath.section];
    [oldSection removeItem:oldItem];
    
    TFTableViewSection *newSection = self.mutableSections[newIndexPath.section];
    [newSection insertItem:oldItem atIndex:newIndexPath.row];
    
    if (self.collectionNode) {
        [self.collectionNode beginUpdates];
        [self.collectionNode moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
        [self.collectionNode endUpdatesAnimated:YES];
    }
    else {
        [self.tableView beginUpdates];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
        [self.tableView endUpdates];
    }
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    if (self.collectionNode) {
#warning 调整方向参数
        [self.collectionNode selectItemAtIndexPath:indexPath animated:animated scrollPosition:0];
    }
    else {
        [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    }
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (self.collectionNode) {
        [self.collectionNode deselectItemAtIndexPath:indexPath animated:animated];
    }
    else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

#pragma mark - UICollectionViewDataSource & ASCollectionDataSource


/**
 * Asks the data source for the number of items in the given section of the collection node.
 *
 * @see @c collectionView:numberOfItemsInSection:
 */
- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section {
    
    TFTableViewSection *tableViewSection = self.mutableSections[section];
    return tableViewSection.items.count;
    
}

/**
 * Asks the data source for the number of sections in the collection node.
 *
 * @see @c numberOfSectionsInCollectionView:
 */
- (NSInteger)numberOfSectionsInCollectionNode:(ASCollectionNode *)collectionNode {
    return self.mutableSections.count;
}

/**
 * Similar to -collectionNode:nodeForItemAtIndexPath:
 * This method takes precedence over collectionNode:nodeForItemAtIndexPath: if implemented.
 *
 * @param collectionNode The sender.
 * @param indexPath The index path of the item.
 *
 * @return a block that creates the node for display for this item.
 *   Must be thread-safe (can be called on the main thread or a background
 *   queue) and should not implement reuse (it will be called once per row).
 */
- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath {
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    Class cellClass = [self _cellClassWithItem:item];
    typeof(self) __weak weakSelf = self;
    return ^{
        TFTableViewItemCellNode *cell = [[cellClass alloc] initWithTableViewItem:item];
        cell.tableViewManager = weakSelf;
        return cell;
    };
}

/**
 * Asks the data source to provide a node-block to display for the given supplementary element in the collection view.
 *
 * @param collectionNode The sender.
 * @param kind           The kind of supplementary element.
 * @param indexPath      The index path of the supplementary element.
 */
//- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
//    Class cellClass = [self _cellClassWithItem:item];
//    typeof(self) __weak weakSelf = self;
//    return ^{
//        TFTableViewItemCellNode *cell = [[cellClass alloc] initWithTableViewItem:item];
//        cell.tableViewManager = weakSelf;
//        return cell;
//    };
//}


/**
 * Asks the data source if it's possible to move the specified item interactively.
 *
 * See @p -[UICollectionViewDataSource collectionView:canMoveItemAtIndexPath:] @c.
 *
 * @param collectionNode  The sender.
 * @param node            The display node for the item that may be moved.
 *
 * @return Whether the item represented by @p node may be moved.
 */
- (BOOL)collectionNode:(ASCollectionNode *)collectionNode canMoveItemWithNode:(ASCellNode *)node {
    if ([node isKindOfClass:[TFTableViewItemCellNode class]]) {
        TFTableViewItem *item = [(TFTableViewItemCellNode *)node tableViewItem];
        return ((item.moveHandler != nil) | (item.moveCompletionHandler != nil));
    }
    return NO;
}

/**
 * Called when the user has interactively moved an item. The data source
 * should update its internal data store to reflect the move. Note that you
 * should not call [collectionNode moveItemAtIndexPath:toIndexPath:] – the
 * collection node's internal state will be updated automatically.
 *
 * * See @p -[UICollectionViewDataSource collectionView:moveItemAtIndexPath:toIndexPath:] @c.
 *
 * @param collectionNode        The sender.
 * @param sourceIndexPath       The original item index path.
 * @param destinationIndexPath  The new item index path.
 */
- (void)collectionNode:(ASCollectionNode *)collectionNode moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    TFTableViewSection *sourceSection = self.mutableSections[sourceIndexPath.section];
    TFTableViewItem *sourceItem = sourceSection.items[sourceIndexPath.row];
    [sourceSection removeItem:sourceItem];
    TFTableViewSection *destinationSection = self.mutableSections[destinationIndexPath.section];
    [destinationSection insertItem:sourceItem atIndex:destinationIndexPath.row];
    if (sourceItem.moveCompletionHandler) {
        sourceItem.moveCompletionHandler (sourceItem,sourceIndexPath,destinationIndexPath);
    }
}

#pragma mark - ASCollectionDelegate

- (ASSizeRange)collectionNode:(ASCollectionNode *)collectionNode constrainedSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionNode:constrainedSizeForItemAtIndexPath:)]) {
        return [self.delegate collectionNode:collectionNode constrainedSizeForItemAtIndexPath:indexPath];
    }
    return ASSizeRangeZero;
}

- (void)collectionNode:(ASCollectionNode *)collectionNode willDisplayItemWithNode:(ASCellNode *)node {
    if ([self.delegate respondsToSelector:@selector(collectionNode:willDisplayItemWithNode:)]) {
        [self.delegate collectionNode:collectionNode willDisplayItemWithNode:node];
    }
}

- (void)collectionNode:(ASCollectionNode *)collectionNode didEndDisplayingItemWithNode:(ASCellNode *)node {
    if ([self.delegate respondsToSelector:@selector(collectionNode:didEndDisplayingItemWithNode:)]) {
        [self.delegate collectionNode:collectionNode didEndDisplayingItemWithNode:node];
    }
}

- (void)collectionNode:(ASCollectionNode *)collectionNode willDisplaySupplementaryElementWithNode:(ASCellNode *)node {
    if ([self.delegate respondsToSelector:@selector(collectionNode:willDisplaySupplementaryElementWithNode:)]) {
        [self.delegate collectionNode:collectionNode willDisplaySupplementaryElementWithNode:node];
    }
}
- (void)collectionNode:(ASCollectionNode *)collectionNode didEndDisplayingSupplementaryElementWithNode:(ASCellNode *)node {
    if ([self.delegate respondsToSelector:@selector(collectionNode:didEndDisplayingSupplementaryElementWithNode:)]) {
        [self.delegate collectionNode:collectionNode didEndDisplayingSupplementaryElementWithNode:node];
    }
}

- (BOOL)collectionNode:(ASCollectionNode *)collectionNode shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionNode:shouldHighlightItemAtIndexPath:)]) {
       return  [self.delegate collectionNode:collectionNode shouldHighlightItemAtIndexPath:indexPath];
    }
    return NO;
}
- (void)collectionNode:(ASCollectionNode *)collectionNode didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionNode:didHighlightItemAtIndexPath:)]) {
        [self.delegate collectionNode:collectionNode didHighlightItemAtIndexPath:indexPath];
    }
}
- (void)collectionNode:(ASCollectionNode *)collectionNode didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionNode:didUnhighlightItemAtIndexPath:)]) {
        [self.delegate collectionNode:collectionNode didUnhighlightItemAtIndexPath:indexPath];
    }
}
- (BOOL)collectionNode:(ASCollectionNode *)collectionNode shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionNode:shouldSelectItemAtIndexPath:)]) {
        return  [self.delegate collectionNode:collectionNode shouldSelectItemAtIndexPath:indexPath];
    }
    return NO;

}

/**
 * Receive a message that the collection node is near the end of its data set and more data should be fetched if
 * necessary.
 *
 * @param collectionNode The sender.
 * @param context A context object that must be notified when the batch fetch is completed.
 *
 * @discussion You must eventually call -completeBatchFetching: with an argument of YES in order to receive future
 * notifications to do batch fetches. This method is called on a background queue.
 *
 * ASCollectionNode currently only supports batch events for tail loads. If you require a head load, consider
 * implementing a UIRefreshControl.
 */
- (void)collectionNode:(ASCollectionNode *)collectionNode willBeginBatchFetchWithContext:(ASBatchContext *)context {
    if ([self.delegate respondsToSelector:@selector(collectionNode:willBeginBatchFetchWithContext:)]) {
        [self.delegate collectionNode:collectionNode willBeginBatchFetchWithContext:context];
    }
}

/**
 * Tell the collection node if batch fetching should begin.
 *
 * @param collectionNode The sender.
 *
 * @discussion Use this method to conditionally fetch batches. Example use cases are: limiting the total number of
 * objects that can be fetched or no network connection.
 *
 * If not implemented, the collection node assumes that it should notify its asyncDelegate when batch fetching
 * should occur.
 */
- (BOOL)shouldBatchFetchForCollectionNode:(ASCollectionNode *)collectionNode {
    if ([self.delegate respondsToSelector:@selector(shouldBatchFetchForCollectionNode:)]) {
        return [self.delegate shouldBatchFetchForCollectionNode:collectionNode];
    }
    return NO;
}


#pragma mark - UITableViewDataSource & ASTableDataSource

#pragma mark unique methods for UITableViewDataSource.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    Class cellClass = [self _cellClassWithItem:item];
    NSString *identifier = item.cellIdentifier;
    if (!identifier) {
        identifier = NSStringFromClass(cellClass);
    }
    TFTableViewItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        NSString *cellName = NSStringFromClass(cellClass);
        //先获取xib存在不存在,存在获取xib
        NSString *nibPath = [[NSBundle mainBundle] pathForResource:cellName ofType:@"nib"];
        if (nibPath) {
            if (!cell) {
                cell = [[[NSBundle mainBundle]loadNibNamed:cellName owner:nil options:nil] lastObject];
                NSAssert([identifier isEqualToString:cell.reuseIdentifier], @"cell reuse idetifier must be equal to the identifier in xib file you set.");
            }
        }
        else {
            if (!cell) {
                cell = [[cellClass alloc] initWithTableViewItem:item reuseIdentifier:identifier];
            }
        }
        // TFTableViewManagerDelegate
        if ([self.delegate respondsToSelector:@selector(tableView:didLoadCellSubViews:forRowAtIndexPath:)]) {
            [self.delegate tableView:tableView didLoadCellSubViews:cell forRowAtIndexPath:indexPath];
        }
        [cell cellLoadSubViews];
        cell.preservesSuperviewLayoutMargins = NO;
        cell.separatorInset = item.separatorInset;
        cell.layoutMargins = item.separatorInset;
    }
    cell.tableViewManager = self;
    cell.tableViewItem = item;
    
    cell.selectionStyle = item.selectionStyle;
    UITableViewCell *lastCell = (UITableViewCell *)item.accessoryView.superview;
    [lastCell.accessoryView removeFromSuperview];
    lastCell.accessoryView = nil;
    if (item.accessoryView) {
        cell.accessoryView = item.accessoryView;
    }
    else {
        cell.accessoryType = item.accessoryType;
    }
    [cell cellWillAppear];
    return cell;
}

- (Class)_cellClassWithItem:(__kindof TFTableViewItem *)item {
    if (item.registerCellClassName.length) {
        Class cellClass = NSClassFromString(item.registerCellClassName);
        NSAssert(cellClass, @"the register cell class name is not exist.");
        return cellClass;
    }
    else {
        NSString *suffix = @"Cell";
        if (_tableNode  || _collectionNode ) {
            suffix = @"CellNode";
        }
        NSString *className = [NSString stringWithFormat:@"%@%@",NSStringFromClass([item class]),suffix];
        Class cellClass = NSClassFromString(className);
        NSAssert(cellClass, @"item matched cell class name is not standard,please use property 'registerCellClassName' to set nonstandard cell class name.");
        return cellClass;
    }
}

#pragma mark unique methods for ASTableDataSource.

- (ASCellNodeBlock)tableView:(ASTableView *)tableView nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    Class cellClass = [self _cellClassWithItem:item];
    typeof(self) __weak weakSelf = self;
    return ^{
        TFTableViewItemCellNode *cell = [[cellClass alloc] initWithTableViewItem:item];
        cell.tableViewManager = weakSelf;
        return cell;
    };
}

#pragma mark the same methods for UITableViewDataSource and ASTableDataSource.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mutableSections.count;
}

-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TFTableViewSection *tableViewSection = self.mutableSections[section];
    return tableViewSection.items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    TFTableViewSection *tableViewSection = self.mutableSections[section];
    return tableViewSection.headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    TFTableViewSection *tableViewSection = self.mutableSections[section];
    return tableViewSection.footerTitle;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    BOOL edit = ((item.editingStyle != UITableViewCellEditingStyleNone) | (item.editActions.count!=0) | (item.edit));
    return edit;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    return ((item.moveHandler != nil) | (item.moveCompletionHandler != nil));
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *titles = [NSMutableArray array];
    for (TFTableViewSection *section in self.mutableSections) {
        if (section.indexTitle.length) {
            [titles addObject:section.indexTitle];
        }
    }
    return titles.count ? titles:nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    TFTableViewSection *tableViewSection = self.mutableSections[index];
    if (tableViewSection.sectionIndex!=-1) {
        return tableViewSection.sectionIndex;
    }
    return index;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleNone:
        {
            
        }
            break;
        case UITableViewCellEditingStyleDelete: {
            TFTableViewItem *item = [self itemAtIndexPath:indexPath];
            if (item.deletionHandler) {
                item.deletionHandler(item,indexPath);
            }
            
        }
            break;
        case UITableViewCellEditingStyleInsert: {
            TFTableViewItem *item = [self itemAtIndexPath:indexPath];
            if (item.insertionHandler) {
                item.insertionHandler(item,indexPath);
            }
        }
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    TFTableViewSection *sourceSection = self.mutableSections[sourceIndexPath.section];
    TFTableViewItem *sourceItem = sourceSection.items[sourceIndexPath.row];
    [sourceSection removeItem:sourceItem];
    TFTableViewSection *destinationSection = self.mutableSections[destinationIndexPath.section];
    [destinationSection insertItem:sourceItem atIndex:destinationIndexPath.row];
    if (sourceItem.moveCompletionHandler) {
        sourceItem.moveCompletionHandler (sourceItem,sourceIndexPath,destinationIndexPath);
    }
}

#pragma mark - UITableViewDelegate & ASTableViewDelegate

#pragma mark unique methods for UITableViewDelegate.

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [(TFTableViewItemCell *)cell cellDidDisappear];
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

#pragma mark unique methods for ASTableViewDelegate.
- (void)tableView:(ASTableView *)tableView willDisplayNodeForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayNodeForRowAtIndexPath:)]) {
        [self.delegate tableView:tableView willDisplayNodeForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(ASTableView *)tableView didEndDisplayingNode:(ASCellNode *)node forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingNode:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didEndDisplayingNode:node forRowAtIndexPath:indexPath];
    }
}

- (BOOL)shouldBatchFetchForTableView:(ASTableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(shouldBatchFetchForTableView:)]) {
        return [self.delegate shouldBatchFetchForTableView:tableView];
    }
    return NO;
}

- (void)tableView:(ASTableView *)tableView willBeginBatchFetchWithContext:(ASBatchContext *)context {
    if ([self.delegate respondsToSelector:@selector(tableView:willBeginBatchFetchWithContext:)]) {
        [self.delegate tableView:tableView willBeginBatchFetchWithContext:context];
    }
}

- (ASSizeRange)tableView:(ASTableView *)tableView constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:constrainedSizeForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView constrainedSizeForRowAtIndexPath:indexPath];
    }
    CGFloat tableViewWidth = CGRectGetWidth(tableView.frame);
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    CGFloat cellHeight = [TFTableViewItemCellNode cellNodeHeightWithItem:item];
    if (cellHeight) {
        return ASSizeRangeMake(CGSizeMake(tableViewWidth, cellHeight), CGSizeMake(tableViewWidth, cellHeight));
    }
    return ASSizeRangeMake(CGSizeMake(tableViewWidth, 0.0),CGSizeMake(tableViewWidth, CGFLOAT_MAX));
}

#pragma mark same methods for UITableViewDelegate and ASTableViewDelegate.

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)]) {
        [self.delegate tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)]) {
        [self.delegate tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)]) {
        [self.delegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)]) {
        [self.delegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    return [[self _cellClassWithItem:item] cellHeightWithItem:item];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.delegate tableView:tableView heightForHeaderInSection:section];
    }
    TFTableViewSection *tableViewSection = self.mutableSections[section];
    if (tableViewSection.headerHeight!=0.0) {
        return tableViewSection.headerHeight;
    }
    if (tableViewSection.headerNode) {
        if (CGSizeEqualToSize(tableViewSection.headerNode.calculatedSize, CGSizeZero) ) {
            [tableViewSection.headerNode layoutThatFits:ASSizeRangeMake(CGSizeMake(tableView.bounds.size.width, 0), CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX))];
            tableViewSection.headerNode.frame = CGRectMake(0, 0, tableViewSection.headerNode.calculatedSize.width, tableViewSection.headerNode.calculatedSize.height);
        }
        return CGRectGetHeight(tableViewSection.headerNode.frame);
    }
    if (tableViewSection.headerView) {
        return CGRectGetHeight(tableViewSection.headerView.frame)? :UITableViewAutomaticDimension;
    }
    if (tableViewSection.headerTitle) {
        CGFloat headerHeight = 0;
        CGFloat headerWidth = CGRectGetWidth(CGRectIntegral(tableView.bounds)) - 40.0f; // 40 = 20pt horizontal padding on each side
        
        CGSize headerRect = CGSizeMake(headerWidth, CGFLOAT_MAX);
        
        CGRect headerFrame = [tableViewSection.headerTitle boundingRectWithSize:headerRect
                                                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                                     attributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] }
                                                                        context:nil];
        
        headerHeight = headerFrame.size.height;
        
        return headerHeight + (self.tableView.style == UITableViewStylePlain ? 20 : 12);
    }
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.delegate tableView:tableView heightForFooterInSection:section];
    }
    TFTableViewSection *tableViewSection = self.mutableSections[section];
    if (tableViewSection.footerHeight!=0.0) {
        return tableViewSection.footerHeight;
    }
    if (tableViewSection.footerNode) {
        if (CGSizeEqualToSize(tableViewSection.footerNode.calculatedSize, CGSizeZero) ) {
            [tableViewSection.footerNode layoutThatFits:ASSizeRangeMake(CGSizeMake(tableView.bounds.size.width, 0), CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX))];
            tableViewSection.footerNode.frame = CGRectMake(0, 0, tableViewSection.footerNode.calculatedSize.width, tableViewSection.footerNode.calculatedSize.height);
        }
        return CGRectGetHeight(tableViewSection.footerNode.frame);
    }
    if (tableViewSection.footerView) {
        return CGRectGetHeight(tableViewSection.footerView.frame)? :UITableViewAutomaticDimension;
    }
    if (tableViewSection.footerTitle) {
        CGFloat footerHeight = 0;
        CGFloat footerWidth = CGRectGetWidth(CGRectIntegral(tableView.bounds)) - 40.0f; // 40 = 20pt horizontal padding on each side
        
        CGSize footerRect = CGSizeMake(footerWidth, CGFLOAT_MAX);
        
        CGRect footerFrame = [tableViewSection.footerTitle boundingRectWithSize:footerRect
                                                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                                     attributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] }
                                                                        context:nil];
        
        footerHeight = footerFrame.size.height;
        
        return footerHeight + 10.0f;
    }
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.delegate tableView:tableView viewForHeaderInSection:section];
    }
    TFTableViewSection *tableViewSection = self.mutableSections[section];
    if (tableViewSection.headerView) {
        return tableViewSection.headerView;
    }
    else if (tableViewSection.reuseHeaderViewClass) {
        NSString *identifier = tableViewSection.headerReuseIdentifier;
        if (!identifier.length) {
            identifier = NSStringFromClass(tableViewSection.reuseHeaderViewClass);
        }
        UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        if (!headerView) {
            headerView = [[tableViewSection.reuseHeaderViewClass alloc] initWithReuseIdentifier:identifier];
        }
        if (tableViewSection.reuseHeaderViewReloadBlock) {
            tableViewSection.reuseHeaderViewReloadBlock(tableViewSection, headerView, section);
        }
        return headerView;
    }
    else if (tableViewSection.headerNode) {
        if (CGSizeEqualToSize(tableViewSection.headerNode.calculatedSize, CGSizeZero) ) {
            [tableViewSection.headerNode layoutThatFits:ASSizeRangeMake(CGSizeMake(tableView.bounds.size.width, 0), CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX))];
            tableViewSection.headerNode.frame = CGRectMake(0, 0, tableViewSection.headerNode.calculatedSize.width, tableViewSection.headerNode.calculatedSize.height);
        }
        return tableViewSection.headerNode.view;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [self.delegate tableView:tableView viewForFooterInSection:section];
    }
    TFTableViewSection *tableViewSection = self.mutableSections[section];
    if (tableViewSection.footerView) {
        return tableViewSection.footerView;
    }
    else if (tableViewSection.reuseFooterViewClass) {
        NSString *identifier = tableViewSection.footerReuseIdentifier;
        if (!identifier.length) {
            identifier = NSStringFromClass(tableViewSection.reuseFooterViewClass);
        }
        UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        if (!footerView) {
            footerView = [[tableViewSection.reuseFooterViewClass alloc] initWithReuseIdentifier:identifier];
        }
        if (tableViewSection.reuseFooterViewReloadBlock) {
            tableViewSection.reuseFooterViewReloadBlock(tableViewSection, footerView, section);
        }
        return footerView;
    }
    else if (tableViewSection.footerNode) {
        if (CGSizeEqualToSize(tableViewSection.footerNode.calculatedSize, CGSizeZero) ) {
            [tableViewSection.footerNode layoutThatFits:ASSizeRangeMake(CGSizeMake(tableView.bounds.size.width, 0), CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX))];
            tableViewSection.footerNode.frame = CGRectMake(0, 0, tableViewSection.footerNode.calculatedSize.width, tableViewSection.footerNode.calculatedSize.height);
        }
        return tableViewSection.footerNode.view;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    if (item.selectionHandler) {
        item.selectionHandler (item,indexPath);
    }
    if (item.cellClickHandler) {
        item.cellClickHandler (item, -1, nil);
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    if (item.editActions) {
        return UITableViewCellEditingStyleDelete;
    }
    return item.editingStyle;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    return item.titleForDelete ? :@"Delete";
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView editActionsForRowAtIndexPath:indexPath];
    }
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    return item.editActions;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    TFTableViewSection *sourceSection = self.mutableSections[sourceIndexPath.section];
    TFTableViewItem *item = sourceSection.items[sourceIndexPath.row];
    if (item.moveHandler) {
        BOOL allowed = item.moveHandler(item, sourceIndexPath, proposedDestinationIndexPath);
        if (!allowed)
        return sourceIndexPath;
    }
    if ([self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]) {
        return [self.delegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
    }
    return proposedDestinationIndexPath;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.delegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:YES];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.delegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.delegate scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.delegate scrollViewDidScrollToTop:scrollView];
    }
}

@end
