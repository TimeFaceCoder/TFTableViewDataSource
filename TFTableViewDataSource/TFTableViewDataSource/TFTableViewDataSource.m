//
//  TFTableViewDataSource.m
//  TFTableViewDataSource
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFTableViewDataSource.h"
#import "TFTableViewDataRequest.h"
#import "TFTableViewDataSourceConfig.h"
#import "TFTableViewDataManager.h"
#import "TFTableViewClassList.h"
#import "TFTableViewItem.h"
#import "TFTableViewItemCell.h"

@interface TFTableViewDataSource()<MYTableViewManagerDelegate> {
    
}

@property (nonatomic ,strong) MYTableViewManager *manager;
/**
 *  网络数据加载工具
 */
@property (nonatomic ,strong) TFTableViewDataRequest *dataRequest;

@property (nonatomic ,strong) TFTableViewDataManager *tableViewDataManager;

@property (nonatomic ,strong) NSMutableDictionary *requestArgument;
@end

@implementation TFTableViewDataSource

- (instancetype)initWithTableView:(ASTableView *)tableView
                         listType:(NSInteger)listType
                           params:(NSDictionary *)params
                         delegate:(id /*<TFTableViewDataSourceDelegate>*/)delegate {
    self = [super init];
    if (!self) {
        return nil;
    }
    _delegate  = delegate;
    _tableView = tableView;
    _listType = listType;
    _requestArgument = [NSMutableDictionary dictionaryWithDictionary:params];
    _manager = [[MYTableViewManager alloc] initWithTableView:tableView delegate:self];
    [self initTableViewPullRefresh];
    [self setupDataSource];
    return self;
}

#pragma mark - Public

- (void)startLoading {
    [self startLoadingWithParams:_requestArgument];
}

- (void)stopLoading {
    _dataSourceState = TFDataSourceStateFinished;
}

- (void)startLoadingWithParams:(NSDictionary *)params {
    if (_requestArgument) {
        [_requestArgument addEntriesFromDictionary:params];
    }
    else {
        _requestArgument = [NSMutableDictionary dictionaryWithDictionary:params];
    }
    [self load:TFDataLoadPolicyNone context:nil];
}


- (void)refreshCell:(NSInteger)actionType identifier:(NSString *)identifier {
    
}


#pragma mark - Private

#pragma mark - 初始化数据加载方法
- (void)setupDataSource {
    NSString *requestURL = [[TFTableViewDataSourceConfig sharedInstance] requestURLByListType:_listType];
    NSString *className = [[TFTableViewDataSourceConfig sharedInstance] classNameByListType:_listType];
    _dataRequest = [[TFTableViewDataRequest alloc] initWithRequestURL:requestURL params:_requestArgument];
    if (className) {
        Class class = NSClassFromString(className);
        _tableViewDataManager = [[class alloc] initWithDataSource:self listType:_listType];
    }
    //registerClass
    NSArray *itemClassList = [TFTableViewClassList subclassesOfClass:[MYTableViewItem class]];
    for (Class itemClass in itemClassList) {
        NSString *itemName = NSStringFromClass(itemClass);
        self.manager[itemName] = [itemName stringByAppendingString:@"Cell"];
    }
}

#pragma mark - 重载以下方法可以自定义下拉刷新组件
////////////////////////////////////////////初始化下拉刷新////////////////////////////////////////////
- (void)initTableViewPullRefresh {
    
}

////////////////////////////////////////////开始下拉刷新//////////////////////////////////////////////
- (void)startTableViewPullRefresh {
    
}

////////////////////////////////////////////结束下拉刷新//////////////////////////////////////////////
- (void)stopTableViewPullRefresh {
    
}

#pragma mark - 数据加载核心方法
////////////////////////////////////////////加载数据//////////////////////////////////////////////////
- (void)load:(TFDataLoadPolicy)loadPolicy context:(ASBatchContext *)context {
    //当前正在加载数据
    if (_dataSourceState == TFDataSourceStateLoading) {
        return;
    }
    if (loadPolicy == TFDataLoadPolicyMore) {
        //加载下一页数据
        if (_currentPage == _totalPage) {
            //加载完所有页码
            _dataSourceState = TFDataSourceStateFinished;
            return;
        }
    } else {
        _currentPage = 1;
        _totalPage = 1;
    }
    [_requestArgument setObject:[NSNumber numberWithInteger:[TFTableViewDataSourceConfig pageSize]]
                         forKey:@"pageSize"];
    [_requestArgument setObject:[NSNumber numberWithInteger:_currentPage] forKey:@"currentPage"];
    //设置操作标示
    _dataSourceState = TFDataSourceStateLoading;
    if ([_dataRequest cacheResponseObject]) {
        //使用缓存数据绘制UI
        [self handleResultData:[_dataRequest cacheResponseObject] dataLoadPolicy:loadPolicy context:context];
    }
    [_dataRequest startWithCompletionBlockWithSuccess:^(__kindof TFBaseRequest *request) {
        [self handleResultData:request.responseObject dataLoadPolicy:loadPolicy context:context];
    } failure:^(__kindof TFBaseRequest *request) {
        TFTableViewLogDebug(@"get data from %@ error :%@ userinfo:%@",request.requestUrl,request.error,request.userInfo);
        [self handleResultData:nil dataLoadPolicy:loadPolicy context:context];
    }];
}

#pragma mark 处理返回数据并绘制UI

- (void)handleResultData:(NSDictionary *)result dataLoadPolicy:(TFDataLoadPolicy)dataLoadPolicy context:(ASBatchContext *)context{
    NSError *hanldeError = nil;
    if (!result) {
        //数据为空
        hanldeError = [NSError errorWithDomain:@"" code:1 userInfo:@{}];
    }
    if (dataLoadPolicy == TFDataLoadPolicyReload) {
        //重新加载列表数据
        [self.manager removeAllSections];
    }
    [self setTotalPage:[[result objectForKey:@"totalPage"] integerValue]];
    if (_totalPage == 0) {
        //数据边界检查
        _totalPage = 1;
        _currentPage = 1;
    }
    if (dataLoadPolicy == TFDataLoadPolicyMore) {
        //加载下一页，移除loading item
        NSInteger lastSectionIndex = [[self.manager sections] count] - 1;
        [self.manager removeLastSection];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:lastSectionIndex]
                                withRowAnimation:UITableViewRowAnimationFade];
        });
    }
    __weak __typeof(self)weakSelf = self;
    [self.tableViewDataManager reloadView:result
                                          block:^(BOOL finished, id object, NSError *error, NSInteger currentItemCount)
     {
         typeof(self) strongSelf = weakSelf;
         if (finished) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 //需要在主线程执行
                 if (_currentPage < _totalPage) {
                     //存在下一页数据，在列表尾部追加loading item
                     NSInteger sectionCount = [strongSelf.manager.sections count];
                     MYTableViewSection *section = [MYTableViewSection section];
                     //loading item
                     [strongSelf.manager addSection:section];
                     [strongSelf.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionCount]
                                         withRowAnimation:UITableViewRowAnimationFade];
                 }
                 //数据加载完成
                 if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(didFinishLoad:error:)]) {
                     [strongSelf.delegate didFinishLoad:dataLoadPolicy error:error?error:hanldeError];
                     [strongSelf stopTableViewPullRefresh];
                 }
                 if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(didFinishLoad:object:error:)]) {
                     [strongSelf.delegate didFinishLoad:dataLoadPolicy object:object error:error?error:hanldeError];
                     [strongSelf stopTableViewPullRefresh];
                 }
                 switch (dataLoadPolicy) {
                     case TFDataLoadPolicyNone:
                         
                         break;
                     case TFDataLoadPolicyMore:
                         if (context) {
                             [context completeBatchFetching:YES];
                         }
                         break;
                     case TFDataLoadPolicyCache:
                         
                         break;
                     case TFDataLoadPolicyReload:
                         
                         break;
                         
                     default:
                         break;
                 }
             });
             strongSelf.dataSourceState = TFDataSourceStateFinished;
         }
     }];
}

#pragma mark - MYTableViewManagerDelegate
/**
 *  列表是否需要加载更多数据
 *
 *  @param tableView
 *
 *  @return
 */
- (BOOL)shouldBatchFetchForTableView:(ASTableView *)tableView {
    return _currentPage < _totalPage;
}
/**
 *  列表开始加载更多数据
 *
 *  @param tableView
 *  @param context
 */
- (void)tableView:(ASTableView *)tableView willBeginBatchFetchWithContext:(ASBatchContext *)context {
    
}


#pragma mark 

- (void)dealloc {
    _manager.delegate = nil;
    _tableView = nil;
    _manager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end