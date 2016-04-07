//
//  TimeLineTableViewItemCell.m
//  TFTableViewDataSource
//
//  Created by Melvin on 4/6/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TimeLineTableViewItemCell.h"
#import "TimeLineTextStyle.h"

@interface TimeLineTableViewItemCell() {
    /**
     *  伪造卡片形式
     */
    ASDisplayNode *_backgroundNode;
    
    ASTextNode          *_nickNameNode;
    ASTextNode          *_timeNode;
    ASTextNode          *_fromNode;
    ASNetworkImageNode  *_avatarNode;
}

@end

@implementation TimeLineTableViewItemCell
@dynamic tableViewItem;
- (void)initCell {
    [super initCell];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _backgroundNode = [[ASDisplayNode alloc] init];
    _backgroundNode.backgroundColor = [UIColor whiteColor];
    _backgroundNode.cornerRadius = 0.0;
    [self addSubnode:_backgroundNode];
    
    // name node
    _nickNameNode = [[ASTextNode alloc] init];
    NSString *nickName = [[self.tableViewItem.model objectForKey:@"author"] objectForKey:@"nickName"];
    _nickNameNode.attributedString = [[NSAttributedString alloc] initWithString:nickName ? nickName: @""
                                                                     attributes:[TimeLineTextStyle nickNameStyle]];
    [_nickNameNode addTarget:self action:@selector(onViewClick:) forControlEvents:ASControlNodeEventTouchUpInside];
    _nickNameNode.maximumNumberOfLines = 1;
    [self addSubnode:_nickNameNode];
    // username node
    _timeNode = [[ASTextNode alloc] init];
    [_timeNode addTarget:self action:@selector(onViewClick:) forControlEvents:ASControlNodeEventTouchUpInside];
    _timeNode.attributedString = [[NSAttributedString alloc] initWithString:@"2016-04-06 17:20"
                                                                 attributes:[TimeLineTextStyle subTextStyle]];
    _timeNode.flexShrink = YES;
    _timeNode.truncationMode = NSLineBreakByTruncatingTail;
    _timeNode.maximumNumberOfLines = 1;
    
    [self addSubnode:_timeNode];
    
    _fromNode = [[ASTextNode alloc] init];
    [_fromNode addTarget:self action:@selector(onViewClick:) forControlEvents:ASControlNodeEventTouchUpInside];
    _fromNode.attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"来自%@",[self.tableViewItem.model objectForKey:@"client"]]
                                                                 attributes:[TimeLineTextStyle subTextStyle]];
    _fromNode.flexShrink = YES;
    _fromNode.truncationMode = NSLineBreakByTruncatingTail;
    _fromNode.maximumNumberOfLines = 1;
    
    [self addSubnode:_fromNode];
    
    // user pic
    _avatarNode = [[ASNetworkImageNode alloc] init];
    [_avatarNode addTarget:self action:@selector(onViewClick:) forControlEvents:ASControlNodeEventTouchUpInside];
    _avatarNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
    _avatarNode.preferredFrameSize = CGSizeMake(44, 44);
    _avatarNode.cornerRadius = 22.0;
    NSString *url = [[self.tableViewItem.model objectForKey:@"author"] objectForKey:@"avatar"];
    _avatarNode.URL = [NSURL URLWithString:url];
    _avatarNode.imageModificationBlock = ^UIImage *(UIImage *image) {
        UIImage *modifiedImage;
        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        UIGraphicsBeginImageContextWithOptions(image.size, false, [[UIScreen mainScreen] scale]);
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:44.0] addClip];
        [image drawInRect:rect];
        modifiedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return modifiedImage;
    };
    [self addSubnode:_avatarNode];
}

- (void)layout {
    [super layout];
    _backgroundNode.frame = CGRectMake(12, 8, self.calculatedSize.width - 24, self.calculatedSize.height- 8);
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    ASLayoutSpec *spacer = [[ASLayoutSpec alloc] init];
    spacer.flexGrow = YES;
    
    ASStackLayoutSpec *nameStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                           spacing:8
                                                                    justifyContent:ASStackLayoutJustifyContentStart
                                                                        alignItems:ASStackLayoutAlignItemsStart
                                                                          children:@[_nickNameNode,_timeNode]];
    nameStack.alignSelf = ASStackLayoutAlignSelfStretch;
    
    
    
    ASStackLayoutSpec *avatarStack = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                                                             spacing:6
                                                                      justifyContent:ASStackLayoutJustifyContentStart
                                                                          alignItems:ASStackLayoutAlignItemsCenter
                                                                            children:@[_avatarNode,nameStack,spacer,_fromNode]];
    avatarStack.alignSelf = ASStackLayoutAlignSelfStretch;
    
    NSMutableArray *mainStackContent = [[NSMutableArray alloc] init];
    [mainStackContent addObject:avatarStack];

       
    
    
    //Vertical spec of cell main content
    ASStackLayoutSpec *contentSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                             spacing:12.0
                                                                      justifyContent:ASStackLayoutJustifyContentStart
                                                                          alignItems:ASStackLayoutAlignItemsStart
                                                                            children:mainStackContent];
    
    
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(20, 24, 20, 24)
                                                  child:contentSpec];
}

- (void)onViewClick:(id)sender {
    
}

@end
