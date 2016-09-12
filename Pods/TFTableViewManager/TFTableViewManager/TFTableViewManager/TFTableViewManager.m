//
//  TFTableViewManager.m
//  TFTableViewManagerDemo
//
//  Created by Summer on 16/8/24.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "TFTableViewManager.h"
#import "TFTableViewItemCell.h"
#import "TFTableViewItemCellNode.h"
#import "TFDefaultTableViewItem.h"

@interface TFTableViewManager ()<UITableViewDataSource,UITableViewDelegate,ASTableDataSource,ASTableDelegate>
{
    CGSize _nodeMinSize;
    CGSize _nodeMaxSize;
}

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

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        tableView.delegate     = self;
        tableView.dataSource   = self;
        self.tableView         = tableView;
        self.registeredClasses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithTableNode:(ASTableNode *)tableNode {
    self = [super init];
    if (self) {
        CGFloat tableNodeWidth = CGRectGetWidth(tableNode.frame);
        CGFloat tableNodeHeight = CGRectGetHeight(tableNode.frame);
        _nodeMinSize = CGSizeMake(tableNodeWidth, 0.0);
        _nodeMaxSize = CGSizeMake(tableNodeWidth, tableNodeHeight);
        tableNode.delegate     = self;
        tableNode.dataSource   = self;
        self.tableNode         = tableNode;
        self.tableView         = tableNode.view;
        self.registeredClasses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (TFTableViewItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    return ((TFTableViewSection *)self.mutableSections[indexPath.section]).items[indexPath.row];
}

#pragma mark - Register Custom Cells

- (void)registerWithItemClass:(NSString *)itemClass cellClass:(NSString *)cellClass
{
    NSAssert(NSClassFromString(itemClass), ([NSString stringWithFormat:@"Item class '%@' does not exist.", itemClass]));
    NSAssert(NSClassFromString(itemClass), ([NSString stringWithFormat:@"Cell class '%@' does not exist.", cellClass]));
    self.registeredClasses[(id <NSCopying>)NSClassFromString(itemClass)] = NSClassFromString(cellClass);
    
    if ([[NSBundle mainBundle] pathForResource:itemClass ofType:@"nib"]) {
        //XIB exists with the same name as the cell class
        [self.tableView registerNib:[UINib nibWithNibName:cellClass bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellClass];
    }
    
}

- (id)objectAtKeyedSubscript:(id <NSCopying>)key
{
    return [self.registeredClasses objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    [self registerWithItemClass:(NSString *)key cellClass:obj];
}

- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath
{
    TFTableViewSection *section = self.mutableSections[indexPath.section];
    NSObject *item = section.items[indexPath.row];
    return self.registeredClasses[item.class];
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
    [self.tableView beginUpdates];
    [self.tableView insertSections:indexSet withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)addSections:(NSArray<TFTableViewSection *> *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.sections.count, sections.count)];
    [self insertSections:sections atIndexes:indexSet withRowAnimation:animation];
}

- (void)deleteSectionsAtIndexSet:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self removeSectionsAtIndexes:sections];
    [self.tableView beginUpdates];
    [self.tableView deleteSections:sections withRowAnimation:animation];
    [self.tableView endUpdates];
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
    [self.tableView beginUpdates];
    [self.tableView reloadSections:sections withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)reloadSections:(NSArray<TFTableViewSection *> *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadSectionsAtIndexSet:[self indexSetWithSections:sections] withRowAnimation:animation];
    
}

- (void)reloadAllSectionsWithRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadSections:self.sections withRowAnimation:animation];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self exchangeSectionAtIndex:section withSectionAtIndex:newSection];
    [self.tableView beginUpdates];
    [self.tableView moveSection:section toSection:newSection];
    [self.tableView endUpdates];
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self.tableView endUpdates];
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
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    for (NSIndexPath *indexPath in indexPaths) {
        TFTableViewSection *section = self.mutableSections[indexPath.section];
        [section removeItemAtIndex:indexPath.row];
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    TFTableViewItem *oldItem = [self itemAtIndexPath:indexPath];
    TFTableViewSection *oldSection = self.mutableSections[indexPath.section];
    [oldSection removeItem:oldItem];
    
    TFTableViewSection *newSection = self.mutableSections[newIndexPath.section];
    [newSection insertItem:oldItem atIndex:newIndexPath.row];
    [self.tableView beginUpdates];
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    [self.tableView endUpdates];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
}

#pragma mark - UITableViewDataSource & ASTableDataSource

#pragma mark unique methods for UITableViewDataSource.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    Class cellClass = [self classForCellAtIndexPath:indexPath];
    NSString *identifier = NSStringFromClass(cellClass);
    if ([item isKindOfClass:[TFDefaultTableViewItem class]]) {
        identifier = [identifier stringByAppendingFormat:@"%ld",(long)((TFDefaultTableViewItem *)item).cellStyle];
    }
    TFTableViewItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[cellClass alloc] initWithTableViewItem:item reuseIdentifier:identifier];
        // TFTableViewManagerDelegate
        if ([self.delegate respondsToSelector:@selector(tableView:didLoadCellSubViews:forRowAtIndexPath:)]) {
            [self.delegate tableView:tableView didLoadCellSubViews:cell forRowAtIndexPath:indexPath];
        }
        [cell cellLoadSubViews];
    }
    cell.tableViewManager = self;
    cell.tableViewItem = item;
    [cell cellWillAppear];
    return cell;
    
}

#pragma mark unique methods for ASTableDataSource.

- (ASCellNodeBlock)tableView:(ASTableView *)tableView nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    Class cellClass = [self classForCellAtIndexPath:indexPath];
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
    BOOL edit = ((item.editingStyle != UITableViewCellEditingStyleNone) | (item.editActions.count!=0));
    return edit;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    return (item.moveHandler != nil);
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
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    if (item.cellHeight) {
        return ASSizeRangeMake(CGSizeMake(_nodeMinSize.width, item.cellHeight), CGSizeMake(_nodeMaxSize.width, item.cellHeight));
    }
    return ASSizeRangeMake(_nodeMinSize, _nodeMaxSize);
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
    return [[self classForCellAtIndexPath:indexPath] heightWithItem:item tableViewManager:self];
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
            [tableViewSection.headerNode measureWithSizeRange:ASSizeRangeMake(CGSizeMake(tableView.bounds.size.width, 0), CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX))];
            tableViewSection.headerNode.frame = CGRectMake(0, 0, tableViewSection.headerNode.calculatedSize.width, tableViewSection.headerNode.calculatedSize.height);
        }
        return CGRectGetHeight(tableViewSection.headerNode.frame);
    }
    if (tableViewSection.headerView) {
        return CGRectGetHeight(tableViewSection.headerView.frame);
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
        
        return headerHeight + 20.0f;
    }
    
    return UITableViewAutomaticDimension;
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
            [tableViewSection.footerNode measureWithSizeRange:ASSizeRangeMake(CGSizeMake(tableView.bounds.size.width, 0), CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX))];
            tableViewSection.footerNode.frame = CGRectMake(0, 0, tableViewSection.footerNode.calculatedSize.width, tableViewSection.footerNode.calculatedSize.height);
        }
        return CGRectGetHeight(tableViewSection.footerNode.frame);
    }
    if (tableViewSection.footerView) {
        return CGRectGetHeight(tableViewSection.footerView.frame);
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
    if (!tableViewSection.headerReuseIdentifier.length) {
        if (tableViewSection.headerNode) {
            if (CGSizeEqualToSize(tableViewSection.headerNode.calculatedSize, CGSizeZero) ) {
                [tableViewSection.headerNode measureWithSizeRange:ASSizeRangeMake(CGSizeMake(tableView.bounds.size.width, 0), CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX))];
                tableViewSection.headerNode.frame = CGRectMake(0, 0, tableViewSection.headerNode.calculatedSize.width, tableViewSection.headerNode.calculatedSize.height);
            }
            return tableViewSection.headerNode.view;
        }
        else {
            return tableViewSection.headerView;
        }
        
    }
    else {
        UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:tableViewSection.headerReuseIdentifier];
        if (!headerView) {
            if ([tableViewSection.headerView isKindOfClass:[UITableViewHeaderFooterView class]]) {
                headerView = (UITableViewHeaderFooterView *)tableViewSection.headerView;
            }
            else {
                NSAssert(headerView, @"headerView is not a UITableViewHeaderFooterView class, can not use as reuse view.");
            }
            headerView = (UITableViewHeaderFooterView *)tableViewSection.headerView;
        }
        return headerView;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [self.delegate tableView:tableView viewForFooterInSection:section];
    }
    TFTableViewSection *tableViewSection = self.mutableSections[section];
    if (!tableViewSection.footerReuseIdentifier.length) {
        if (tableViewSection.footerNode) {
            if (CGSizeEqualToSize(tableViewSection.footerNode.calculatedSize, CGSizeZero) ) {
                [tableViewSection.footerNode measureWithSizeRange:ASSizeRangeMake(CGSizeMake(tableView.bounds.size.width, 0), CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX))];
                tableViewSection.footerNode.frame = CGRectMake(0, 0, tableViewSection.footerNode.calculatedSize.width, tableViewSection.footerNode.calculatedSize.height);
            }
            return tableViewSection.footerNode.view;
        }
        else {
            return tableViewSection.footerView;
        }
        
    }
    else {
        UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:tableViewSection.footerReuseIdentifier];
        if (!footerView) {
            if ([tableViewSection.footerView isKindOfClass:[UITableViewHeaderFooterView class]]) {
                footerView = (UITableViewHeaderFooterView *)tableViewSection.footerView;
            }
            else {
                NSAssert(footerView, @"footView is not a UITableViewHeaderFooterView class, can not use as reuse view.");
            }
        }
        return footerView;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    TFTableViewItem *item = [self itemAtIndexPath:indexPath];
    if (item.selectionHandler) {
        item.selectionHandler (item,indexPath);
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
    if ([self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]) {
        return [self.delegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
    }
    return proposedDestinationIndexPath;
}



@end
