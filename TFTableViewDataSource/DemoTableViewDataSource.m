//
//  DemoTableViewDataSource.m
//  TFTableViewDataSource
//
//  Created by Melvin on 4/5/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "DemoTableViewDataSource.h"
#import <UzysAnimatedGifPullToRefresh/UIScrollView+UzysAnimatedGifPullToRefresh.h>
@interface DemoTableViewDataSource() {
    
}

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
    
}

- (void)startTableViewPullRefresh {
    [self.tableView triggerPullToRefresh];
}

- (void)stopTableViewPullRefresh {
    [self.tableView stopPullToRefreshAnimation];
    [super stopTableViewPullRefresh];
}

@end
