//
//  PFUITableViewItemCell.m
//  TFTableViewManagerDemo
//
//  Created by Summer on 16/8/26.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "TFTableViewItemCell.h"
#import "TFTableViewItem.h"

@interface TFTableViewItemCell ()

@end

@implementation TFTableViewItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (instancetype)initWithTableViewItem:(TFTableViewItem *)tableViewItem reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tableViewItem = tableViewItem;
    }
    [self cellLoadSubViews];
    return self;
}


#pragma mark - Handling Cell Events.

+ (CGFloat)heightWithItem:(TFTableViewItem *)item tableViewManager:(TFTableViewManager *)tableViewManager
{
    return UITableViewAutomaticDimension;
}

#pragma mark - Cell life cycle

- (void)cellLoadSubViews {
    
    //add subviews at here.
    self.selectionStyle = self.tableViewItem.selectionStyle;
    self.accessoryType = self.tableViewItem.accessoryType;
    if (self.tableViewItem.accessoryView) {
        self.accessoryView = self.tableViewItem.accessoryView;
    }
    if (!self.tableViewItem.separatorSunk) {
        self.preservesSuperviewLayoutMargins = NO;
        UIEdgeInsets lineInsets =  UIEdgeInsetsZero;
        self.separatorInset = lineInsets;
        self.layoutMargins = lineInsets;
    }
   
}

- (void)cellWillAppear {
    //set subviews property values at here.
    
}

- (void)cellDidDisappear {
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
