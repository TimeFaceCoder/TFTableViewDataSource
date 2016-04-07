//
//  MYTableViewCell.m
//  MYTableViewManager
//
//  Created by Melvin on 12/15/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "MYTableViewCell.h"
#import "MYTableViewItem.h"

@interface MYTableViewCell()

@property (nonatomic ,strong) ASDisplayNode *dividerNode;

@end

@implementation MYTableViewCell


- (instancetype)initWithTableViewItem:(MYTableViewItem *)tableViewItem {
    self = [super init];
    if(self) {
        self.tableViewItem = tableViewItem;
        
        // hairline cell separator
        if (self.tableViewItem.separatorStyle != UITableViewCellSeparatorStyleNone) {
            _dividerNode = [[ASDisplayNode alloc] init];
            _dividerNode.backgroundColor = self.tableViewItem.dividerColor;
            [self addSubnode:_dividerNode];
        }
        [self initCell];
    }
    return self;
}

- (void)initCell {
    
}

- (void)didLoad {
    // enable highlighting now that self.layer has loaded -- see ASHighlightOverlayLayer.h
    self.layer.as_allowsHighlightDrawing = YES;
    [super didLoad];
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    return nil;
}

- (void)layout {
    [super layout];
    CGFloat pixelHeight = 1.0f / [[UIScreen mainScreen] scale];
    _dividerNode.frame = CGRectMake(0.0f, 0.0f, self.calculatedSize.width, pixelHeight);
}

@end
