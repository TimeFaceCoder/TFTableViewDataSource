//
//  ViewController.m
//  TFTableViewDataSource
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "ViewController.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "DemoTableViewDataSource.h"
@interface ViewController ()

@property (nonatomic ,strong) DemoTableViewDataSource *dataSource;
@property (nonatomic ,strong) ASTableView           *tableView;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    _tableView = [[ASTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain asyncDataFetching:YES];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
   
}
- (void)viewWillLayoutSubviews {
    _tableView.frame = self.view.bounds;
}
- (void)createDataSource {
    self.dataSource = [[DemoTableViewDataSource alloc] initWithTableView:self.tableView
                                                                listType:1
                                                                  params:@{}
                                                                delegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createDataSource];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.dataSource startLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
