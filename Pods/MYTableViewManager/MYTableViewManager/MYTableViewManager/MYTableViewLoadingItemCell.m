//
//  MYTableViewLoadingItemCell.m
//  MYTableViewManager
//
//  Created by Melvin on 12/22/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "MYTableViewLoadingItemCell.h"

@interface MYTableViewLoadingItemCell() {
    ASTextNode *_titleNode;
}
@end


@implementation MYTableViewLoadingItemCell
@dynamic tableViewItem;

- (void)initCell {
    [super initCell];
    _titleNode = [[ASTextNode alloc] init];
    _titleNode.attributedString = [[NSAttributedString alloc] initWithString:self.tableViewItem.title
                                                                  attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:15.0],NSForegroundColorAttributeName: [UIColor blackColor]}];
    _titleNode.maximumNumberOfLines = 1;
    [self addSubnode:_titleNode];
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

@end
