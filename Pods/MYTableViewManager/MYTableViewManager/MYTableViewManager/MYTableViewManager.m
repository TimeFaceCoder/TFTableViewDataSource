//
//  MYTableViewManager.m
//  MYTableViewManager
//
//  Created by Melvin on 12/15/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "MYTableViewManager.h"

@interface MYTableViewManager ()

@property (nonatomic, strong) NSMutableArray *mutableSections;
@property (nonatomic, assign) CGFloat defaultTableViewSectionHeight;
@property (atomic, assign) BOOL dataSourceLocked;

@end

@implementation MYTableViewManager

- (instancetype)initWithTableView:(ASTableView *)tableView delegate:(id<MYTableViewManagerDelegate>)delegate {
    self = [self initWithTableView:tableView];
    if (!self)
        return nil;
    
    self.delegate = delegate;
    
    return self;
}

- (id)initWithTableView:(ASTableView *)tableView
{
    self = [super init];
    if (!self)
        return nil;
    
    tableView.asyncDelegate = self;
    tableView.asyncDataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView = tableView;
    
    self.mutableSections = [[NSMutableArray alloc] init];
    self.registeredClasses = [[NSMutableDictionary alloc] init];
    
    [self registerDefaultClasses];
    
    return self;
}

- (void)registerDefaultClasses
{
    self[@"__NSCFConstantString"] = @"MYTableViewCell";
    self[@"__NSCFString"] = @"MYTableViewCell";
    self[@"NSString"] = @"MYTableViewCell";
    self[@"MYTableViewItem"] = @"MYTableViewCell";
}


- (void)registerClass:(NSString *)objectClass forCellWithReuseIdentifier:(NSString *)identifier {
    NSAssert(NSClassFromString(objectClass), ([NSString stringWithFormat:@"Item class '%@' does not exist.", objectClass]));
    NSAssert(NSClassFromString(identifier), ([NSString stringWithFormat:@"Cell class '%@' does not exist.", identifier]));
    self.registeredClasses[(id <NSCopying>)NSClassFromString(objectClass)] = NSClassFromString(identifier);
}

- (id)objectAtKeyedSubscript:(id <NSCopying>)key
{
    return [self.registeredClasses objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    [self registerClass:(NSString *)key forCellWithReuseIdentifier:obj];
}

- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath {
    MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    NSObject *item = [section.items objectAtIndex:indexPath.row];
    return [self.registeredClasses objectForKey:item.class];
}
- (NSArray *)sections
{
    return self.mutableSections;
}

- (CGFloat)defaultTableViewSectionHeight
{
    return self.tableView.style == UITableViewStyleGrouped ? 44 : 22;
}


#pragma mark -
#pragma mark ASTableViewDataSource.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mutableSections.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.mutableSections.count <= section) {
        return 0;
    }
    return ((MYTableViewSection *)[self.mutableSections objectAtIndex:section]).items.count;
}

- (ASCellNode *)tableView:(ASTableView *)tableView nodeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    MYTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    
    Class cellClass = [self classForCellAtIndexPath:indexPath];
    MYTableViewCell *cell = [[cellClass alloc] initWithTableViewItem:item];
    
    
    cell.rowIndex = indexPath.row;
    cell.sectionIndex = indexPath.section;
    return cell;
}

- (void)tableViewLockDataSource:(ASTableView *)tableView
{
    self.dataSourceLocked = YES;
}

- (void)tableViewUnlockDataSource:(ASTableView *)tableView
{
    self.dataSourceLocked = NO;
}

#pragma mark - 
#pragma mark - ASTableViewDelegate.

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

- (NSArray *)sectionIndexTitlesForTableView:(ASTableView *)tableView {
    NSMutableArray *titles;
    for (MYTableViewSection *section in self.mutableSections) {
        if (section.indexTitle) {
            titles = [NSMutableArray array];
            break;
        }
    }
    if (titles) {
        for (MYTableViewSection *section in self.mutableSections) {
            [titles addObject:section.indexTitle ? section.indexTitle : @""];
        }
    }
    
    return titles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.mutableSections.count <= section) {
        return nil;
    }
    MYTableViewSection *tableViewSection = [self.mutableSections objectAtIndex:section];
    return tableViewSection.headerTitle;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.mutableSections.count <= section) {
        return nil;
    }
    MYTableViewSection *tableViewSection = [self.mutableSections objectAtIndex:section];
    return tableViewSection.footerTitle;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    MYTableViewSection *sourceSection = [self.mutableSections objectAtIndex:sourceIndexPath.section];
    MYTableViewItem *item = [sourceSection.items objectAtIndex:sourceIndexPath.row];
    [sourceSection removeItemAtIndex:sourceIndexPath.row];
    
    MYTableViewSection *destinationSection = [self.mutableSections objectAtIndex:destinationIndexPath.section];
    [destinationSection insertItem:item atIndex:destinationIndexPath.row];
    
    if (item.moveCompletionHandler)
        item.moveCompletionHandler(item, sourceIndexPath, destinationIndexPath);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mutableSections.count <= indexPath.section) {
        return NO;
    }
    MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    MYTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    return item.moveHandler != nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [self.mutableSections count]) {
        MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
        if (indexPath.row < [section.items count]) {
            MYTableViewItem *item = [section.items objectAtIndex:indexPath.row];
            if ([item isKindOfClass:[MYTableViewItem class]]) {
                return item.editingStyle != UITableViewCellEditingStyleNone || item.moveHandler;
            }
        }
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
        MYTableViewItem *item = [section.items objectAtIndex:indexPath.row];
        if (item.deletionHandlerWithCompletion) {
            item.deletionHandlerWithCompletion(item, ^{
                [section removeItemAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                for (NSInteger i = indexPath.row; i < section.items.count; i++) {
                    MYTableViewItem *afterItem = [[section items] objectAtIndex:i];
                    MYTableViewCell *cell = (MYTableViewCell *)[tableView cellForRowAtIndexPath:afterItem.indexPath];
                    cell.rowIndex--;
                }
            });
        } else {
            if (item.deletionHandler)
                item.deletionHandler(item);
            [section removeItemAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            for (NSInteger i = indexPath.row; i < section.items.count; i++) {
                MYTableViewItem *afterItem = [[section items] objectAtIndex:i];
                MYTableViewCell *cell = (MYTableViewCell *)[tableView cellForRowAtIndexPath:afterItem.indexPath];
                cell.rowIndex--;
            }
        }
    }
    
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
        MYTableViewItem *item = [section.items objectAtIndex:indexPath.row];
        if (item.insertionHandler)
            item.insertionHandler(item);
    }
}

- (void)tableView:(ASTableView *)tableView willDisplayNodeForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(my_tableView:willLoadCell:forRowAtIndexPath:)]) {
        MYTableViewCell *cell = (MYTableViewCell *)[tableView nodeForRowAtIndexPath:indexPath];
        [self.delegate my_tableView:tableView willLoadCell:cell forRowAtIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark Table view delegate

// Display customization
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)])
        [self.delegate tableView:tableView willDisplayHeaderView:view forSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)])
        [self.delegate tableView:tableView willDisplayFooterView:view forSection:section];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)])
        [self.delegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)])
        [self.delegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (self.mutableSections.count <= sectionIndex) {
        return UITableViewAutomaticDimension;
    }
    MYTableViewSection *section = [self.mutableSections objectAtIndex:sectionIndex];
    
    if (section.headerHeight != MYTableViewSectionHeaderHeightAutomatic) {
        return section.headerHeight;
    }
    
    if (section.headerView) {
        return section.headerView.frame.size.height;
    } else if (section.headerTitle.length) {
        if (!UITableViewStyleGrouped) {
            return self.defaultTableViewSectionHeight;
        } else {
            CGFloat headerHeight = 0;
            CGFloat headerWidth = CGRectGetWidth(CGRectIntegral(tableView.bounds)) - 40.0f; // 40 = 20pt horizontal padding on each side
            
            CGSize headerRect = CGSizeMake(headerWidth, MYTableViewSectionHeaderHeightAutomatic);
            
            CGRect headerFrame = [section.headerTitle boundingRectWithSize:headerRect
                                                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                                attributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] }
                                                                   context:nil];
            
            headerHeight = headerFrame.size.height;
            
            return headerHeight + 20.0f;
        }
    }
    
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
        return [self.delegate tableView:tableView heightForHeaderInSection:sectionIndex];
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)sectionIndex
{
    if (self.mutableSections.count <= sectionIndex) {
        return UITableViewAutomaticDimension;
    }
    MYTableViewSection *section = [self.mutableSections objectAtIndex:sectionIndex];
    
    if (section.footerHeight != MYTableViewSectionFooterHeightAutomatic) {
        return section.footerHeight;
    }
    
    if (section.footerView) {
        return section.footerView.frame.size.height;
    } else if (section.footerTitle.length) {
        if (!UITableViewStyleGrouped) {
            return self.defaultTableViewSectionHeight;
        } else {
            CGFloat footerHeight = 0;
            CGFloat footerWidth = CGRectGetWidth(CGRectIntegral(tableView.bounds)) - 40.0f; // 40 = 20pt horizontal padding on each side
            
            CGSize footerRect = CGSizeMake(footerWidth, MYTableViewSectionFooterHeightAutomatic);
            
            CGRect footerFrame = [section.footerTitle boundingRectWithSize:footerRect
                                                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                                attributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] }
                                                                   context:nil];
            
            footerHeight = footerFrame.size.height;
            
            return footerHeight + 10.0f;
        }
    }
    
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)])
        return [self.delegate tableView:tableView heightForFooterInSection:sectionIndex];
    
    return UITableViewAutomaticDimension;
}


// Section header & footer information. Views are preferred over title should you decide to provide both

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (self.mutableSections.count <= sectionIndex) {
        return nil;
    }
    MYTableViewSection *section = [self.mutableSections objectAtIndex:sectionIndex];
    
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
        return [self.delegate tableView:tableView viewForHeaderInSection:sectionIndex];
    
    return section.headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)sectionIndex
{
    if (self.mutableSections.count <= sectionIndex) {
        return nil;
    }
    MYTableViewSection *section = [self.mutableSections objectAtIndex:sectionIndex];
    
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)])
        return [self.delegate tableView:tableView viewForFooterInSection:sectionIndex];
    
    return section.footerView;
}

// Accessories (disclosures).

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    id item = [section.items objectAtIndex:indexPath.row];
    if ([item respondsToSelector:@selector(setAccessoryButtonTapHandler:)]) {
        MYTableViewItem *actionItem = (MYTableViewItem *)item;
        if (actionItem.accessoryButtonTapHandler)
            actionItem.accessoryButtonTapHandler(item);
    }
    
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)])
        [self.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

// Selection

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)])
        return [self.delegate tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)])
        [self.delegate tableView:tableView didHighlightRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)])
        [self.delegate tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
        return [self.delegate tableView:tableView willSelectRowAtIndexPath:indexPath];
    
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)])
        return [self.delegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_tableView beginUpdates];
    MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    id item = [section.items objectAtIndex:indexPath.row];
    if ([item respondsToSelector:@selector(setSelectionHandler:)]) {
        MYTableViewItem *actionItem = (MYTableViewItem *)item;
        if (actionItem.selectionHandler)
            actionItem.selectionHandler(item);
    }
    
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [_tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)])
        [self.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

// Editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    MYTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    
    if (![item isKindOfClass:[MYTableViewItem class]])
        return UITableViewCellEditingStyleNone;
    
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)])
        return [self.delegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    
    return item.editingStyle;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)])
        return [self.delegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    
    return NSLocalizedString(@"Delete", @"Delete");
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)])
        return [self.delegate tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
    
    return YES;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)])
        [self.delegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)])
        [self.delegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
}

// Moving/reordering

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    MYTableViewSection *sourceSection = [self.mutableSections objectAtIndex:sourceIndexPath.section];
    MYTableViewItem *item = [sourceSection.items objectAtIndex:sourceIndexPath.row];
    if (item.moveHandler) {
        BOOL allowed = item.moveHandler(item, sourceIndexPath, proposedDestinationIndexPath);
        if (!allowed)
            return sourceIndexPath;
    }
    
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)])
        return [self.delegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
    
    return proposedDestinationIndexPath;
}

// Indentation

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)])
        return [self.delegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    
    return 0;
}

// Copy/Paste.  All three methods must be implemented by the delegate.

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    id anItem = [section.items objectAtIndex:indexPath.row];
    if ([anItem respondsToSelector:@selector(setCopyHandler:)]) {
        MYTableViewItem *item = anItem;
        if (item.copyHandler || item.pasteHandler)
            return YES;
    }
    
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:)])
        return [self.delegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    id anItem = [section.items objectAtIndex:indexPath.row];
    if ([anItem respondsToSelector:@selector(setCopyHandler:)]) {
        MYTableViewItem *item = anItem;
        if (item.copyHandler && action == @selector(copy:))
            return YES;
        
        if (item.pasteHandler && action == @selector(paste:))
            return YES;
        
        if (item.cutHandler && action == @selector(cut:))
            return YES;
    }
    
    // Forward to UITableViewDelegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)])
        return [self.delegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    MYTableViewSection *section = [self.mutableSections objectAtIndex:indexPath.section];
    MYTableViewItem *item = [section.items objectAtIndex:indexPath.row];
    
    if (action == @selector(copy:)) {
        if (item.copyHandler)
            item.copyHandler(item);
    }
    
    if (action == @selector(paste:)) {
        if (item.pasteHandler)
            item.pasteHandler(item);
    }
    
    if (action == @selector(cut:)) {
        if (item.cutHandler)
            item.cutHandler(item);
    }
    
    // Forward to UITableView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UITableViewDelegate)] && [self.delegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)])
        [self.delegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
        [self.delegate scrollViewDidScroll:self.tableView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidZoom:)])
        [self.delegate scrollViewDidZoom:self.tableView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
        [self.delegate scrollViewWillBeginDragging:self.tableView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
        [self.delegate scrollViewWillEndDragging:self.tableView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
        [self.delegate scrollViewDidEndDragging:self.tableView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
        [self.delegate scrollViewWillBeginDecelerating:self.tableView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
        [self.delegate scrollViewDidEndDecelerating:self.tableView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
        [self.delegate scrollViewDidEndScrollingAnimation:self.tableView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
        return [self.delegate viewForZoomingInScrollView:self.tableView];
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
        [self.delegate scrollViewWillBeginZooming:self.tableView withView:view];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
        [self.delegate scrollViewDidEndZooming:self.tableView withView:view atScale:scale];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
        return [self.delegate scrollViewShouldScrollToTop:self.tableView];
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.delegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
        [self.delegate scrollViewDidScrollToTop:self.tableView];
}

#pragma mark -
#pragma mark Managing sections

- (void)addSection:(MYTableViewSection *)section
{
    section.tableViewManager = self;
    [self.mutableSections addObject:section];
}

- (void)addSectionsFromArray:(NSArray *)array
{
    for (MYTableViewSection *section in array)
        section.tableViewManager = self;
    [self.mutableSections addObjectsFromArray:array];
}

- (void)insertSection:(MYTableViewSection *)section atIndex:(NSUInteger)index
{
    section.tableViewManager = self;
    [self.mutableSections insertObject:section atIndex:index];
}

- (void)insertSections:(NSArray *)sections atIndexes:(NSIndexSet *)indexes
{
    for (MYTableViewSection *section in sections)
        section.tableViewManager = self;
    [self.mutableSections insertObjects:sections atIndexes:indexes];
}

- (void)removeSection:(MYTableViewSection *)section
{
    [self.mutableSections removeObject:section];
}

- (void)removeAllSections
{
    [self.mutableSections removeAllObjects];
}

- (void)removeSectionIdenticalTo:(MYTableViewSection *)section inRange:(NSRange)range
{
    [self.mutableSections removeObjectIdenticalTo:section inRange:range];
}

- (void)removeSectionIdenticalTo:(MYTableViewSection *)section
{
    [self.mutableSections removeObjectIdenticalTo:section];
}

- (void)removeSectionsInArray:(NSArray *)otherArray
{
    [self.mutableSections removeObjectsInArray:otherArray];
}

- (void)removeSectionsInRange:(NSRange)range
{
    [self.mutableSections removeObjectsInRange:range];
}

- (void)removeSection:(MYTableViewSection *)section inRange:(NSRange)range
{
    [self.mutableSections removeObject:section inRange:range];
}

- (void)removeLastSection
{
    [self.mutableSections removeLastObject];
}

- (void)removeSectionAtIndex:(NSUInteger)index
{
    [self.mutableSections removeObjectAtIndex:index];
}

- (void)removeSectionsAtIndexes:(NSIndexSet *)indexes
{
    [self.mutableSections removeObjectsAtIndexes:indexes];
}

- (void)replaceSectionAtIndex:(NSUInteger)index withSection:(MYTableViewSection *)section
{
    section.tableViewManager = self;
    [self.mutableSections replaceObjectAtIndex:index withObject:section];
}

- (void)replaceSectionsWithSectionsFromArray:(NSArray *)otherArray
{
    [self removeAllSections];
    [self addSectionsFromArray:otherArray];
}

- (void)replaceSectionsAtIndexes:(NSIndexSet *)indexes withSections:(NSArray *)sections
{
    for (MYTableViewSection *section in sections)
        section.tableViewManager = self;
    [self.mutableSections replaceObjectsAtIndexes:indexes withObjects:sections];
}

- (void)replaceSectionsInRange:(NSRange)range withSectionsFromArray:(NSArray *)otherArray range:(NSRange)otherRange
{
    for (MYTableViewSection *section in otherArray)
        section.tableViewManager = self;
    [self.mutableSections replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange];
}

- (void)replaceSectionsInRange:(NSRange)range withSectionsFromArray:(NSArray *)otherArray
{
    [self.mutableSections replaceObjectsInRange:range withObjectsFromArray:otherArray];
}

- (void)exchangeSectionAtIndex:(NSUInteger)idx1 withSectionAtIndex:(NSUInteger)idx2
{
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

@end
