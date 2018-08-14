//
//  TFLoadingTableViewItemCell.m
//  TFTableViewDataSource
//
//  Created by Summer on 16/9/9.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "TFLoadingTableViewItemCell.h"

@interface TFLoadingTableViewItemCell ()

@property (strong ,nonatomic) UILabel *loadingLabel;

@end

@implementation TFLoadingTableViewItemCell

@dynamic tableViewItem;

+ (CGFloat)cellHeightWithItem:(TFTableViewItem *)item {
    return 60.0;
}

- (void)cellLoadSubViews {
    [super cellLoadSubViews];
    [self.contentView addSubview:self.loadingLabel];
    NSDictionary *viewDic = @{@"loadingLabel":self.loadingLabel};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[loadingLabel]-0-|" options:0 metrics:nil views:viewDic]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[loadingLabel]-0-|" options:0 metrics:nil views:viewDic]];
}

- (void)cellWillAppear {
    [super cellWillAppear];
    self.loadingLabel.text = self.tableViewItem.model;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - lazy load.

- (UILabel *)loadingLabel {
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc]init];
        _loadingLabel.font = [UIFont systemFontOfSize:15];
        _loadingLabel.textColor = [UIColor lightGrayColor];
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        _loadingLabel.numberOfLines = 0;
        _loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _loadingLabel;
}


@end
