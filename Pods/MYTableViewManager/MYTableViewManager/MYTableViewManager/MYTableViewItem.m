//
//  MYTableViewItem.m
//  MYTableViewManager
//
//  Created by Melvin on 12/15/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "MYTableViewItem.h"
#import "MYTableViewSection.h"
#import "MYTableViewManager.h"

@implementation MYTableViewItem

+ (instancetype)item {
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    _dividerColor = [UIColor lightGrayColor];
    return self;
}

- (NSIndexPath *)indexPath {
//    return nil;
        return [NSIndexPath indexPathForRow:[self.section.items indexOfObject:self] inSection:self.section.index];
}

#pragma mark -
#pragma mark Manipulating table view row

- (void)selectRowAnimated:(BOOL)animated {
    [self selectRowAnimated:animated scrollPosition:UITableViewScrollPositionNone];
}

- (void)selectRowAnimated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    [self.section.tableViewManager.tableView selectRowAtIndexPath:self.indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)deselectRowAnimated:(BOOL)animated {
    [self.section.tableViewManager.tableView deselectRowAtIndexPath:self.indexPath animated:animated];
}

- (void)reloadRowWithAnimation:(UITableViewRowAnimation)animation {
    [self.section.tableViewManager.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:animation];
}

- (void)deleteRowWithAnimation:(UITableViewRowAnimation)animation {
    MYTableViewSection *section = self.section;
    NSInteger row = self.indexPath.row;
    [section removeItemAtIndex:self.indexPath.row];
    [section.tableViewManager.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section.index]] withRowAnimation:animation];
}
@end
