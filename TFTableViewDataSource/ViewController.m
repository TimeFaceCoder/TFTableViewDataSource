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
#import "TFTableViewDataSourceConfig.h"

@interface ViewController ()<TFTableViewDataSourceDelegate>

@property (nonatomic ,strong) DemoTableViewDataSource *dataSource;
@property (nonatomic ,strong) ASTableNode           *tableNode;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    
    _tableNode = [[ASTableNode alloc] initWithStyle:UITableViewStylePlain];
    _tableNode.frame = self.view.bounds;
//    __weak ViewController* wself = self;
//    _tableNode.layoutSpecBlock = ^ASLayoutSpec* (ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize){
//        
//        return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(8, 8, 8, 8) child:wself.tableNode];
////        return nil;
//    };
    [self.view addSubnode:self.tableNode];
    _tableNode.backgroundColor = [UIColor lightGrayColor];
}

- (void)createDataSource {
    self.dataSource = [[[[TFTableViewDataSourceConfig sharedInstance] dataSourceByListType:1] alloc] initWithTableNode:_tableNode listType:1 params:@{} delegate:self];
    self.dataSource.cacheTimeInSeconds = 60;
    self.dataSource.pageSize = 5;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.tableNode measure:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createDataSource];
    [self.dataSource startLoading];
    self.dataSource.manager[@"TimeLineTableViewItem"] = @"TimeLineTableViewItemCellNode";
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    self.tableNode.view.tableFooterView = [[UIView alloc] init];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s",__func__);
}
@end
