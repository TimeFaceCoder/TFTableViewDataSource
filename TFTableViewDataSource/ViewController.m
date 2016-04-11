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
@interface ViewController ()<TFTableViewDataSourceDelegate>

@property (nonatomic ,strong) DemoTableViewDataSource *dataSource;
@property (nonatomic ,strong) ASTableView           *tableView;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    _tableView = [[ASTableView alloc] initWithFrame:self.view.bounds
                                              style:UITableViewStylePlain
                                  asyncDataFetching:YES];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor lightGrayColor];
}

- (void)createDataSource {
    self.dataSource = [[DemoTableViewDataSource alloc] initWithTableView:self.tableView
                                                                listType:1
                                                                  params:@{}
                                                                delegate:self];
    self.dataSource.cacheTimeInSeconds = 60;
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

/**
 *  列表及其控件点击事件回调
 *
 *  @param item
 *  @param actionType 事件类型
 */
- (void)actionOnView:(TFTableViewItem *)item actionType:(NSInteger)actionType {
    
}
/**
 *  开始加载
 */
- (void)didStartLoad {
    
}
/**
 *  加载完成
 *
 *  @param loadPolicy 加载类型
 *  @param error      错误
 */
- (void)didFinishLoad:(TFDataLoadPolicy)loadPolicy object:(id)object error:(NSError *)error {
    self.tableView.tableFooterView = [[UIView alloc] init];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s",__func__);
}
@end
