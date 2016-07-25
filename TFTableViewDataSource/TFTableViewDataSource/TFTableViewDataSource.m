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

#import <MYTableViewManager/MYTableViewLoadingItem.h>
#import <MYTableViewManager/MYTableViewLoadingItemCell.h>

@interface TFTableViewDataSource()<MYTableViewManagerDelegate> {
    
}

/**
 *  向上滚动阈值
 */
@property (nonatomic ,assign) CGFloat                  upThresholdY;
/**
 *  向下阈值
 */
@property (nonatomic ,assign) CGFloat                  downThresholdY;
/**
 *  当前滚动方向
 */
@property (nonatomic ,assign) NSInteger                previousScrollDirection;
/**
 *  Y轴偏移
 */
@property (nonatomic ,assign) CGFloat                  previousOffsetY;
/**
 *  Y积累总量
 */
@property (nonatomic ,assign) CGFloat                  accumulatedY;

@property (nonatomic ,strong) MYTableViewManager       *manager;
/**
 *  网络数据加载工具
 */
@property (nonatomic ,strong) TFTableViewDataRequest   *dataRequest;

@property (nonatomic ,strong) TFTableViewDataManager   *tableViewDataManager;

@property (nonatomic ,strong) NSMutableDictionary      *requestArgument;

@property (nonatomic ,assign) BOOL                     firstLoadOver;

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
    _listType  = listType;
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
    [self stopTableViewPullRefresh];
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
    if (_tableViewDataManager) {
        [_tableViewDataManager refreshCell:actionType identifier:identifier];
    }
}


#pragma mark - Private

#pragma mark - 初始化数据加载方法
- (void)setupDataSource {
    _downThresholdY = 200.0;
    _upThresholdY = 25.0;
    
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

- (void)loadMore {
    if (_currentPage < _totalPage) {
        [self load:TFDataLoadPolicyMore context:nil];
    }
}
#pragma mark - 重载以下方法可以自定义下拉刷新组件
////////////////////////////////////////////初始化下拉刷新////////////////////////////////////////////
- (void)initTableViewPullRefresh {
    TFTableViewLogDebug(@"%s",__func__);
}

////////////////////////////////////////////开始下拉刷新//////////////////////////////////////////////
- (void)startTableViewPullRefresh {
    TFTableViewLogDebug(@"%s",__func__);
    _firstLoadOver = YES;
    [self load:TFDataLoadPolicyReload context:nil];
}

////////////////////////////////////////////结束下拉刷新//////////////////////////////////////////////
- (void)stopTableViewPullRefresh {
    TFTableViewLogDebug(@"%s",__func__);
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
        _currentPage++;
    } else {
        _currentPage = 1;
        _totalPage = 1;
    }
    [_requestArgument setObject:[NSNumber numberWithInteger:[TFTableViewDataSourceConfig pageSize]]
                         forKey:@"pageSize"];
    [_requestArgument setObject:[NSNumber numberWithInteger:_currentPage] forKey:@"currentPage"];
    _dataRequest.requestArgument    = _requestArgument;
    _dataRequest.cacheTimeInSeconds = _cacheTimeInSeconds;
    //设置操作标示
    _dataSourceState = TFDataSourceStateLoading;
    //加载第一页时候使用缓存数据
    if ([_dataRequest cacheResponseObject] && !_firstLoadOver) {
        //使用缓存数据绘制UI
        TFTableViewLogDebug(@"use cache data for %@",_dataRequest.requestURL);
        [self handleResultData:[_dataRequest cacheResponseObject]
                dataLoadPolicy:TFDataLoadPolicyCache
                       context:context
                         error:nil];
    }
    else {
        [_dataRequest startWithCompletionBlockWithSuccess:^(__kindof TFBaseRequest *request) {
            TFTableViewLogDebug(@"get data from server %@ page:%@",request.requestUrl,@(_currentPage));
            [self handleResultData:request.responseObject dataLoadPolicy:loadPolicy context:context error:nil];
        } failure:^(__kindof TFBaseRequest *request) {
            TFTableViewLogDebug(@"get data from %@ error :%@ userinfo:%@",request.requestUrl,request.error,request.userInfo);
            if ([request cacheResponseObject]) {
                [self handleResultData:[request cacheResponseObject]
                        dataLoadPolicy:loadPolicy
                               context:context
                                 error:nil];
            }
            else {
                [self handleResultData:nil
                        dataLoadPolicy:loadPolicy
                               context:context
                                 error:request.error];
            }
        }];
    }
}

#pragma mark 处理返回数据并绘制UI

- (void)handleResultData:(NSDictionary *)result
          dataLoadPolicy:(TFDataLoadPolicy)dataLoadPolicy
                 context:(ASBatchContext *)context
                   error:(NSError *)error {
    TFTableViewLogDebug(@"%s",__func__);
    NSError *hanldeError = nil;
    NSInteger lastSectionIndex = [[self.manager sections] count] - 1;
    if (!result || [[result objectForKey:@"dataList"] count] <= 0) {
        //数据为空
        hanldeError = [NSError errorWithDomain:@"" code:1 userInfo:@{}];
    }
    if (dataLoadPolicy == TFDataLoadPolicyMore) {
        //加载下一页，移除loading item
        [self.manager removeLastSection];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:lastSectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
        });
    }
    [self setTotalPage:[[result objectForKey:@"totalPage"] integerValue]];
    if (_totalPage == 0) {
        //数据边界检查
        _totalPage = 1;
        _currentPage = 1;
    }
    __weak __typeof(self)weakSelf = self;
    [self.tableViewDataManager reloadView:result
                                    block:^(BOOL finished, id object, NSError *error, NSArray <MYTableViewSection *> *sections)
     {
         typeof(self) strongSelf = weakSelf;
         if (finished) {
             if (dataLoadPolicy == TFDataLoadPolicyReload || dataLoadPolicy == TFDataLoadPolicyNone) {
                 //重新加载列表数据
                 [strongSelf.manager removeAllSections];
             }
             NSInteger rangelocation = [strongSelf.manager.sections count];
             [strongSelf.manager addSectionsFromArray:sections];
             NSInteger rangelength = 1;
             //需要在主线程执行
             if (_currentPage < _totalPage) {
                 //存在下一页数据，在列表尾部追加loading item
                 MYTableViewSection *section = [MYTableViewSection section];
                 //loading item
                 [section addItem:[MYTableViewLoadingItem itemWithTitle:NSLocalizedString(@"正在加载...", nil)]];
                 [strongSelf.manager addSection:section];
                 rangelength += sections.count;
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (dataLoadPolicy == TFDataLoadPolicyMore) {
                     [strongSelf.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(rangelocation, rangelength)]
                                         withRowAnimation:UITableViewRowAnimationFade];
                     if (context) {
                         [context completeBatchFetching:YES];
                     }
                 }
                 else {
                     [strongSelf reloadTableView];
                     strongSelf.firstLoadOver = YES;
                     if (dataLoadPolicy == TFDataLoadPolicyReload) {
                         [strongSelf stopTableViewPullRefresh];
                     }
                     if (dataLoadPolicy == TFDataLoadPolicyCache) {
                         //第一次从缓存加载数据后延迟触发下拉刷新重新加载
                         [strongSelf performSelector:@selector(startTableViewPullRefresh)
                                          withObject:nil
                                          afterDelay:0.75];
                     }
                 }
                 //数据加载完成
                 if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(didFinishLoad:object:error:)]) {
                     [strongSelf.delegate didFinishLoad:dataLoadPolicy object:object error:error?error:hanldeError];
                 }
             });
             strongSelf.dataSourceState = TFDataSourceStateFinished;
         }
     }];
}

#pragma mark - 刷新列表
- (void)reloadTableView {
    UIView *snapshot = [self.tableView snapshotViewAfterScreenUpdates:NO];
    [self.tableView.superview insertSubview:snapshot aboveSubview:_tableView];
    [self.tableView beginUpdates];
    [self.tableView reloadDataImmediately];
    [self.tableView endUpdatesAnimated:NO completion:^(BOOL completed) {
        [UIView animateWithDuration:0.75 animations:^{
            snapshot.alpha = 0;
        } completion:^(BOOL finished) {
            [snapshot removeFromSuperview];
        }];
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
    TFTableViewLogDebug(@"Class %@ will fetch next page",NSStringFromClass(self.class));
    [self load:TFDataLoadPolicyMore context:context];
}

#pragma mark - UIScrollViewDelegate
- (void)tableView:(UITableView *)tableView willLayoutCellSubviews:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath; {
    
}
- (void)tableView:(UITableView *)tableView willLoadCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath; {
    
}

- (void)tableView:(UITableView *)tableView didLoadCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath; {
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(ASTableView *)tableView willDisplayNodeForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayNodeForRowAtIndexPath:)]) {
        [self.delegate tableView:tableView willDisplayNodeForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(ASTableView *)tableView didEndDisplayingNode:(ASCellNode *)node forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingNode:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didEndDisplayingNode:node forRowAtIndexPath:indexPath];
    }
}

/**
 *  滚动方向判断
 *
 *  @param currentOffsetY
 *  @param previousOffsetY
 *
 *  @return ScrollDirection
 */
- (NSInteger)detectScrollDirection:(CGFloat)currentOffsetY previousOffsetY:(CGFloat)previousOffsetY {
    return currentOffsetY > previousOffsetY ? TFTableViewScrollDirectionUp   :
    currentOffsetY < previousOffsetY ? TFTableViewScrollDirectionDown :
    TFTableViewScrollDirectionNone;
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"删除", nil);
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray
                                           arrayWithObjects:indexPath,nil]
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_delegate scrollViewDidScroll:_tableView];
    }
    
    
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    NSInteger currentScrollDirection = [self detectScrollDirection:currentOffsetY previousOffsetY:_previousOffsetY];
    CGFloat topBoundary = -scrollView.contentInset.top;
    CGFloat bottomBoundary = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    BOOL isOverTopBoundary = currentOffsetY <= topBoundary;
    BOOL isOverBottomBoundary = currentOffsetY >= bottomBoundary;
    
    BOOL isBouncing = (isOverTopBoundary && currentScrollDirection != TFTableViewScrollDirectionDown) || (isOverBottomBoundary && currentScrollDirection != TFTableViewScrollDirectionUp);
    if (isBouncing || !scrollView.isDragging) {
        return;
    }
    
    CGFloat deltaY = _previousOffsetY - currentOffsetY;
    _accumulatedY += deltaY;
    
    if (currentScrollDirection == TFTableViewScrollDirectionUp) {
        BOOL isOverThreshold = _accumulatedY < -_upThresholdY;
        
        if (isOverThreshold || isOverBottomBoundary)  {
            if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidScrollUp:)]) {
                [_delegate scrollViewDidScrollUp:deltaY];
            }
        }
    }
    else if (currentScrollDirection == TFTableViewScrollDirectionDown) {
        BOOL isOverThreshold = _accumulatedY > _downThresholdY;
        
        if (isOverThreshold || isOverTopBoundary) {
            if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidScrollDown:)]) {
                [_delegate scrollViewDidScrollDown:deltaY];
            }
        }
    }
    else {
        
    }
    
    
    // reset acuumulated y when move opposite direction
    if (!isOverTopBoundary && !isOverBottomBoundary && _previousScrollDirection != currentScrollDirection) {
        _accumulatedY = 0;
    }
    
    _previousScrollDirection = currentScrollDirection;
    _previousOffsetY = currentOffsetY;
    
    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    
    CGFloat topBoundary = -scrollView.contentInset.top;
    CGFloat bottomBoundary = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (_previousScrollDirection == TFTableViewScrollDirectionUp) {
        BOOL isOverThreshold = _accumulatedY < -_upThresholdY;
        BOOL isOverBottomBoundary = currentOffsetY >= bottomBoundary;
        
        if (isOverThreshold || isOverBottomBoundary) {
            if ([_delegate respondsToSelector:@selector(scrollFullScreenScrollViewDidEndDraggingScrollUp)]) {
                [_delegate scrollFullScreenScrollViewDidEndDraggingScrollUp];
            }
        }
    }
    else if (_previousScrollDirection == TFTableViewScrollDirectionDown) {
        BOOL isOverThreshold = _accumulatedY > _downThresholdY;
        BOOL isOverTopBoundary = currentOffsetY <= topBoundary;
        
        if (isOverThreshold || isOverTopBoundary) {
            if ([_delegate respondsToSelector:@selector(scrollFullScreenScrollViewDidEndDraggingScrollDown)]) {
                [_delegate scrollFullScreenScrollViewDidEndDraggingScrollDown];
            }
        }
    }
    else {
        
    }
}


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    BOOL ret = YES;
    if ([_delegate respondsToSelector:@selector(scrollFullScreenScrollViewDidEndDraggingScrollDown)]) {
        [_delegate scrollFullScreenScrollViewDidEndDraggingScrollDown];
    }
    return ret;
}



#pragma mark

- (void)dealloc {
    _manager.delegate = nil;
    _tableView = nil;
    _manager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end