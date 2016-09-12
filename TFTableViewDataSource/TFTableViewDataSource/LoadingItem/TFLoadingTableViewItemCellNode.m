//
//  TFLoadingTableViewItemCellNode.m
//  TFTableViewDataSource
//
//  Created by Summer on 16/9/9.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "TFLoadingTableViewItemCellNode.h"

@interface TFLoadingTableViewItemCellNode ()

@property (nonatomic, strong) ASTextNode *titleNode;

@end

@implementation TFLoadingTableViewItemCellNode

@dynamic tableViewItem;

- (void)cellLoadSubNodes {
    [super cellLoadSubNodes];
    [self addSubnode:self.titleNode];
    _titleNode.attributedText = [[NSAttributedString alloc] initWithString:self.tableViewItem.model
                                                                attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:15.0],NSForegroundColorAttributeName: [UIColor blackColor]}];
}

- (void)layout {
    [super layout];
    
    _titleNode.frame = CGRectMake((self.calculatedSize.width - _titleNode.calculatedSize.width)/2, (self.calculatedSize.height - _titleNode.calculatedSize.height)/2, _titleNode.calculatedSize.width, _titleNode.calculatedSize.height);
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    ASStackLayoutSpec *contentSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                             spacing:8.0
                                                                      justifyContent:ASStackLayoutJustifyContentCenter
                                                                          alignItems:ASStackLayoutAlignItemsStart
                                                                            children:@[_titleNode]];
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(12, 12, 12, 12)
                                                  child:contentSpec];
}


#pragma mark - lazy load.

- (ASTextNode *)titleNode {
    if (!_titleNode) {
        _titleNode = [[ASTextNode alloc] init];
        _titleNode.maximumNumberOfLines = 1;
    }
    return _titleNode;
}

@end
