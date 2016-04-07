//
//  MYTableViewCell.h
//  MYTableViewManager
//
//  Created by Melvin on 12/15/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@class MYTableViewManager,MYTableViewItem;

@interface MYTableViewCell : ASCellNode

@property (nonatomic, weak) MYTableViewManager *tableViewManager;
@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, strong) MYTableViewItem *tableViewItem;


- (instancetype)initWithTableViewItem:(MYTableViewItem *)tableViewItem;
- (void)initCell;

@end
