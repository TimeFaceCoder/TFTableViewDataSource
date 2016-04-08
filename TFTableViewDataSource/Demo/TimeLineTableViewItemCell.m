//
//  TimeLineTableViewItemCell.m
//  TFTableViewDataSource
//
//  Created by Melvin on 4/6/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TimeLineTableViewItemCell.h"
#import "TimeLineTextStyle.h"
#import <YYDispatchQueuePool/YYDispatchQueuePool.h>

@interface TimeLineTableViewItemCell() {
    /**
     *  伪造卡片形式
     */
    ASDisplayNode *_backgroundNode;
    
    ASTextNode          *_nickNameNode;
    ASTextNode          *_timeNode;
    ASTextNode          *_fromNode;
    ASNetworkImageNode  *_avatarNode;
    ASTextNode          *_titleNode;
    ASTextNode          *_contentNode;
}

@end

@implementation TimeLineTableViewItemCell
@dynamic tableViewItem;
- (void)initCell {
    [super initCell];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _backgroundNode = [[ASDisplayNode alloc] init];
    _backgroundNode.backgroundColor = [UIColor whiteColor];
    _backgroundNode.cornerRadius = 4.0;
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
    NSTimeInterval date = [[self.tableViewItem.model objectForKey:@"date"] doubleValue];
    [_timeNode addTarget:self action:@selector(onViewClick:) forControlEvents:ASControlNodeEventTouchUpInside];
    _timeNode.attributedString = [[NSAttributedString alloc] initWithString:[self formattedDateWithDate:[NSDate dateWithTimeIntervalSince1970:date] format:@"yyyy-MM-dd HH:mm"]                                                                 attributes:[TimeLineTextStyle subTextStyle]];
    
    
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
    
    // title node
    _titleNode = [[ASTextNode alloc] init];
    [_titleNode addTarget:self action:@selector(onViewClick:) forControlEvents:ASControlNodeEventTouchUpInside];
    _titleNode.attributedString = [[NSAttributedString alloc] initWithString:[self.tableViewItem.model objectForKey:@"timeTitle"]
                                                                  attributes:[TimeLineTextStyle titleStyle]];
    _titleNode.flexShrink = YES;
    _titleNode.truncationMode = NSLineBreakByTruncatingTail;
    _titleNode.maximumNumberOfLines = 1;
    
    [self addSubnode:_titleNode];
    
    // post node
    _contentNode = [[ASTextNode alloc] init];
    _contentNode.maximumNumberOfLines = 4;
    [_contentNode addTarget:self action:@selector(onViewClick:) forControlEvents:ASControlNodeEventTouchUpInside];
    
    // processing URLs in post
    NSString *kLinkAttributeName = @"TextLinkAttributeName";
    
    @autoreleasepool {
        if([self.tableViewItem.model objectForKey:@"content"]) {
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[self.tableViewItem.model objectForKey:@"content"] attributes:[TimeLineTextStyle contentStyle]];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:12];
            [attrString addAttribute:NSParagraphStyleAttributeName
                               value:paragraphStyle
                               range:NSMakeRange(0, attrString.string.length)];
            
            // configure node to support tappable links
            _contentNode.userInteractionEnabled = YES;
            _contentNode.linkAttributeNames = @[ kLinkAttributeName ];
            _contentNode.attributedString = attrString;
            //_contentNode.backgroundColor = [UIColor redColor];
            
        }
    }
    
    [self addSubnode:_contentNode];
}


- (NSString *)formattedDateWithDate:(NSDate *)date format:(NSString *)format {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
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
    
    [mainStackContent addObject:_titleNode];
    [mainStackContent addObject:_contentNode];
    
    
    
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
