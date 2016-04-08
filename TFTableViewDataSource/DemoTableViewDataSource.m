//
//  DemoTableViewDataSource.m
//  TFTableViewDataSource
//
//  Created by Melvin on 4/5/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "DemoTableViewDataSource.h"
#import <UzysAnimatedGifPullToRefresh/UIScrollView+UzysAnimatedGifPullToRefresh.h>
#import <POP/POP.h>

@interface DemoTableViewDataSource() {
    
}
@property (nonatomic ,strong) NSMutableSet *showIndexes;

@end

@implementation DemoTableViewDataSource

- (void)initTableViewPullRefresh {
    NSMutableArray *progress =[NSMutableArray array];
    for (int i=1;i<=20;i++) {
        NSString *fname = [NSString stringWithFormat:@"Loading%02d",i];
        [progress addObject:[UIImage imageNamed:fname]];
    }
    [self.tableView addPullToRefreshActionHandler:^{
        [super startTableViewPullRefresh];
    }
                                   ProgressImages:progress
                                    LoadingImages:progress
                          ProgressScrollThreshold:60
                           LoadingImagesFrameRate:60];
    _showIndexes = [NSMutableSet new];

}

- (void)startTableViewPullRefresh {
    [self.tableView triggerPullToRefresh];
}

- (void)stopTableViewPullRefresh {
    [self.tableView stopPullToRefreshAnimation];
    [super stopTableViewPullRefresh];
}

- (void)tableView:(ASTableView *)tableView willDisplayNodeForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayNodeForRowAtIndexPath:)]) {
        [self.delegate tableView:tableView willDisplayNodeForRowAtIndexPath:indexPath];
    }
    //自定义动画效果
    if (indexPath.section == 0) {
        //第一组列表
        if (![self.showIndexes containsObject:indexPath]) {
            [self.showIndexes addObject:indexPath];
            CGFloat rotationAngleDegrees = -30;
            CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI/ 180);
            CGPoint offsetPositioning = CGPointMake(-80, -80);
            
            
            CATransform3D transform = CATransform3DIdentity;
            transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0,  0.0, 1.0);
            transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y , 0.0);
            ASCellNode *node = [tableView nodeForRowAtIndexPath:indexPath];
            
            node.layer.transform = transform;
            node.alpha = 0.7;
            [UIView animateWithDuration:1
                                  delay:0.0
                 usingSpringWithDamping:0.6f
                  initialSpringVelocity:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 node.layer.transform = CATransform3DIdentity;
                                 node.layer.opacity = 1;
                             }
                             completion:nil];
        }
    }
}

- (void)dealloc {
    [_showIndexes removeAllObjects];
    _showIndexes = nil;
}
@end
