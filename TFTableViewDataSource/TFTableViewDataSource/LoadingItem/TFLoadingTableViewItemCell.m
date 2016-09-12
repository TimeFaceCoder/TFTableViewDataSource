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

@property (strong ,nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation TFLoadingTableViewItemCell

@dynamic tableViewItem;

+ (CGFloat)heightWithItem:(TFTableViewItem *)item tableViewManager:(TFTableViewManager *)tableViewManager {
    return 60.0;
}

- (void)cellLoadSubViews {
    [super cellLoadSubViews];
    [self.contentView addSubview:self.loadingView];
    [self.contentView addSubview:self.loadingLabel];
}

- (void)cellWillAppear {
    [super cellWillAppear];
    self.textLabel.text = self.tableViewItem.model;
    [self.loadingView startAnimating];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.loadingView.center = self.contentView.center;
    [self.loadingLabel sizeToFit];
    self.loadingLabel.center = CGPointMake(0, CGRectGetMidY(self.loadingView.frame));
    CGFloat left = (CGRectGetWidth(self.frame) - (CGRectGetWidth(self.loadingView.frame) + CGRectGetWidth(self.loadingLabel.frame)) ) / 2;
    CGRect loadViewframe = self.loadingView.frame;
    loadViewframe.origin.x = left;
    self.loadingView.frame = loadViewframe;
    CGRect loadingLabelFrame = self.loadingLabel.frame;
    loadingLabelFrame.origin.x = CGRectGetMaxX(loadViewframe) + 6.0;
    self.loadingLabel.frame = loadingLabelFrame;
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
        _loadingLabel.font = [UIFont systemFontOfSize:14];
        _loadingLabel.textColor = [UIColor lightGrayColor];
    }
    return _loadingLabel;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _loadingView;
}


@end
