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
#import "TFLoadingTableViewItem.h"
#import "TFLoadingTableViewItemCell.h"
#import "LoadDataOperation.h"
@interface TFTableViewDataSource()<TFTableViewManagerDelegate> {
    
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

@property (nonatomic ,strong) TFTableViewManager       *manager;
/**
 *  网络数据加载工具
 */
@property (nonatomic ,strong) TFTableViewDataRequest   *dataRequest;


@property (nonatomic ,strong) TFTableViewDataManager   *tableViewDataManager;

@property (nonatomic ,strong) NSMutableDictionary      *requestArgument;

@property (nonatomic ,assign) BOOL                     loadCacheDataOver;


@property (nonatomic, strong) NSOperationQueue* loadDataOperationQueue;
@end

@implementation TFTableViewDataSource

#pragma mark - 初始化方法

- (instancetype)initWithTableView:(UITableView *)tableView
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
    _manager = [[TFTableViewManager alloc] initWithTableView:tableView];
    _manager.delegate = self;
    
    [self initTableViewPullRefresh];
    [self setupDataSource];
    return self;
}

- (instancetype)initWithTableNode:(ASTableNode *)tableNode
                         listType:(NSInteger)listType
                           params:(NSDictionary *)params
                         delegate:(id)delegate {
    self = [super init];
    if (!self) {
        return nil;
    }
    _delegate  = delegate;
    _tableNode = tableNode;
    _tableView = tableNode.view;
    _listType  = listType;
    _requestArgument = [NSMutableDictionary dictionaryWithDictionary:params];
    _manager = [[TFTableViewManager alloc] initWithTableNode:tableNode];
    _manager.delegate = self;
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
    _loadCacheDataOver = NO;
    [self loadDataWithPolicy:TFDataLoadPolicyNone context:nil];
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
    NSString *className = [[TFTableViewDataSourceConfig sharedInstance] classNameByListType:_listType];
    if (className) {
        Class class = NSClassFromString(className);
        _tableViewDataManager = [[class alloc] initWithDataSource:self listType:_listType];
    }
    //registerClass
    NSArray *itemClassList = [TFTableViewClassList subclassesOfClass:[TFTableViewItem class]];
    for (Class itemClass in itemClassList) {
        NSString *itemName = NSStringFromClass(itemClass);
        if (NSClassFromString([itemName stringByAppendingString:@"CellNode"]) && self.tableNode) {
            self.manager[itemName] = [itemName stringByAppendingString:@"CellNode"];
        }
        else if (NSClassFromString([itemName stringByAppendingString:@"Cell"]) && self.tableView) {
            self.manager[itemName] = [itemName stringByAppendingString:@"Cell"];
        }
    }
    
    _loadDataOperationQueue = [[NSOperationQueue alloc]init];
    _loadDataOperationQueue.maxConcurrentOperationCount = 1;
    _loadDataOperationQueue.qualityOfService = NSQualityOfServiceBackground;
}

- (void)loadMore {
    if (_currentPage < _totalPage) {
        [self loadDataWithPolicy:TFDataLoadPolicyMore context:nil];
    }
}

#pragma mark - 重载以下方法可以自定义下拉刷新组件

- (void)initTableViewPullRefresh {
    TFTableViewLogDebug(@"%s",__func__);
}

- (void)startTableViewPullRefresh {
    TFTableViewLogDebug(@"%s",__func__);
    [self loadDataWithPolicy:TFDataLoadPolicyReload context:nil];
}

- (void)stopTableViewPullRefresh {
    TFTableViewLogDebug(@"%s",__func__);
}

#pragma mark - 数据加载核心方法

- (void)loadDataWithPolicy:(TFDataLoadPolicy)loadPolicy context:(ASBatchContext *)context{
    
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
    
    if (self.pageSize > 0) {
        [_requestArgument setObject:@(self.pageSize) forKey:@"pageSize"];
    }
    else {
        [_requestArgument setObject:@([TFTableViewDataSourceConfig pageSize])
                             forKey:@"pageSize"];
        
    }
    [_requestArgument setObject:@(_currentPage) forKey:@"currentPage"];
    _dataRequest.requestArgument    = _requestArgument;
    _dataRequest.cacheTimeInSeconds = _cacheTimeInSeconds;
    //设置操作标示
    _dataSourceState = TFDataSourceStateLoading;
    NSString *requestURL = [[TFTableViewDataSourceConfig sharedInstance] requestURLByListType:_listType];
    _dataRequest = [[TFTableViewDataRequest alloc] initWithRequestURL:requestURL params:_requestArgument];
    LoadDataOperation* opeartion = [[LoadDataOperation alloc]initWithRequest:_dataRequest dataLoadPolocy:loadPolicy firstLoadOver:self.loadCacheDataOver];
    __weak TFTableViewDataSource* wself = self;
    __weak LoadDataOperation* wOperation = opeartion;
    _loadCacheDataOver = YES;
    [opeartion setCompletionBlock:^{
        [wself handleResultData:wOperation.result
                 dataLoadPolicy:wOperation.policy
                        context:context
                          error:nil];
    }];
    [self.loadDataOperationQueue addOperation:opeartion];
    
}

#pragma mark 处理返回数据并绘制UI

- (void)handleResultData:(NSDictionary *)result
          dataLoadPolicy:(TFDataLoadPolicy)dataLoadPolicy
                 context:(ASBatchContext *)context
                   error:(NSError *)error {
    TFTableViewLogDebug(@"%s",__func__);
    NSError *hanldeError = nil;
    
    
    [self setTotalPage:[[result objectForKey:@"totalPage"] integerValue]];
    if (_totalPage == 0) {
        //数据边界检查
        _totalPage = 1;
        _currentPage = 1;
    }
    __weak __typeof(self)weakSelf = self;
    [self.tableViewDataManager reloadView:result
                                    block:^(BOOL finished, id object, NSError *error, NSArray <TFTableViewSection *> *sections)
     {
         typeof(self) strongSelf = weakSelf;
         if (finished) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSInteger lastSectionIndex = strongSelf.manager.sections.count - 1;
                 if (dataLoadPolicy == TFDataLoadPolicyMore) {
                     [strongSelf.tableView beginUpdates];
                     //加载下一页，移除loading item
                     [self.manager removeSectionsAtIndexes:[NSIndexSet indexSetWithIndex:lastSectionIndex]];
                     [strongSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:lastSectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                     //重新载入新的section和loadsection
                     [strongSelf addNewAndLoadingSectionsWith:sections];
                     [strongSelf.tableView endUpdates];
                     [context completeBatchFetching:YES];
                 }
                 else {
                     if (strongSelf.tableNode) {
                         UIView *snapshot = [self.tableView snapshotViewAfterScreenUpdates:NO];
                         [strongSelf.tableView.superview insertSubview:snapshot aboveSubview:strongSelf.tableView];
                         [strongSelf.tableView beginUpdates];
                         //重新加载列表数据
                         NSInteger sectionCount = self.manager.sections.count;
                         [strongSelf.manager removeAllSections];
                         [strongSelf.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sectionCount)]
                                             withRowAnimation:UITableViewRowAnimationFade];
                         //重新载入新的section和loadsection
                         [strongSelf addNewAndLoadingSectionsWith:sections];
                         [strongSelf.tableNode.view endUpdatesAnimated:NO completion:^(BOOL completed) {
                             [UIView animateWithDuration:0.75 animations:^{
                                 snapshot.alpha = 0;
                             } completion:^(BOOL finished) {
                                 [snapshot removeFromSuperview];
                             }];
                         }];
                     }
                     else {
                         [strongSelf.tableView beginUpdates];
                         //重新加载列表数据
                         NSInteger sectionCount = self.manager.sections.count;
                         [strongSelf.manager removeAllSections];
                         [strongSelf.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sectionCount)]
                                             withRowAnimation:UITableViewRowAnimationFade];
                         //重新载入新的section和loadsection
                         [strongSelf addNewAndLoadingSectionsWith:sections];
                         [strongSelf.tableView endUpdates];
                     }
                }
                 //数据加载完成
                 if (dataLoadPolicy == TFDataLoadPolicyReload) {
                     [strongSelf stopTableViewPullRefresh];
                 }
                 if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(didFinishLoad:object:error:)]) {
                     [strongSelf.delegate didFinishLoad:dataLoadPolicy object:object error:error?error:hanldeError];
                 }
                 strongSelf.dataSourceState = TFDataSourceStateFinished;
             });
             
         }
     }];
}

- (void)addNewAndLoadingSectionsWith:(NSArray *)sections {
    NSInteger rangelocation = self.manager.sections.count;
    [self.manager addSectionsFromArray:sections];
    NSInteger rangelength = 1;
    //需要在主线程执行
    if (_currentPage < _totalPage) {
        //存在下一页数据，在列表尾部追加loading item
        TFTableViewSection *section = [TFTableViewSection section];
        //loading item
        [section addItem:[TFLoadingTableViewItem itemWithModel:NSLocalizedString(@"正在加载...", nil)]];
        [self.manager addSection:section];
        rangelength += sections.count;
    }
    [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(rangelocation, rangelength)]
                        withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark - UITableViewDelegate & ASTableViewDelegate

#pragma mark unique methods for UITableViewDelegate.

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[TFLoadingTableViewItemCell class]]) {
        [self performSelector:@selector(loadMore) withObject:nil afterDelay:0.3];
    }
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didLoadCellSubViews:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didLoadCellSubViews:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didLoadCellSubViews:cell forRowAtIndexPath:indexPath];
    }
}

#pragma mark unique methods for ASTableViewDelegate.
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

- (BOOL)shouldBatchFetchForTableView:(ASTableView *)tableView {
    return _currentPage < _totalPage;
}

- (void)tableView:(ASTableView *)tableView willBeginBatchFetchWithContext:(ASBatchContext *)context {
    TFTableViewLogDebug(@"Class %@ will fetch next page",NSStringFromClass(self.class));
    [self loadDataWithPolicy:TFDataLoadPolicyMore context:context];
}

#pragma mark same methods for UITableViewDelegate and ASTableViewDelegate.

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)]) {
        [self.delegate tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)]) {
        [self.delegate tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)]) {
        [self.delegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)]) {
        [self.delegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}




#pragma mark - UIScrollViewDelegate

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

- (void)dealloc {
    _manager.delegate = nil;
    _tableView = nil;
    _manager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
