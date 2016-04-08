//
//  DemoTableViewDataSource.m
//  TFTableViewDataSource
//
//  Created by Melvin on 4/5/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "DemoTableViewDataSource.h"

@interface DemoTableViewDataSource() {
    
}

@property (nonatomic ,strong) UIRefreshControl *refreshControl;

@end

@implementation DemoTableViewDataSource

- (void)initTableViewPullRefresh {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(startTableViewPullRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)startTableViewPullRefresh {
    [super startTableViewPullRefresh];
}

- (void)stopTableViewPullRefresh {
    [self.refreshControl endRefreshing];
    [super stopTableViewPullRefresh];
}

@end
