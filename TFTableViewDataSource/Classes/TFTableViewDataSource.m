//
//  TFTableViewDataSource.m
//  TFTableViewDataSource
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFTableViewDataSource.h"
#import "TFTableViewDataSourceConfig.h"
#import "TFTableViewDataManager.h"
#import "TFTableViewManagerKit.h"
#import "TFLoadingTableViewItem.h"
#import "TFLoadingTableViewItemCell.h"
//数据请求
#import "LoadDataOperation.h"
#import <TFNetwork/TFBatchRequest.h>

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
@property (nonatomic ,strong, readwrite) TFTableViewDataRequest   *dataRequest;

@property (nonatomic, strong) TFBatchRequest *dataBatchRequest;

@property (nonatomic ,strong) TFTableViewDataManager   *tableViewDataManager;

@property (nonatomic ,strong) NSMutableDictionary      *requestArgument;

@property (nonatomic ,assign) BOOL                     loadCacheDataOver;

@property (nonatomic ,assign) BOOL                     isCollectionNode;

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
    _batchShouldLoadInFirstPage = YES;
    _delegate  = delegate;
    _tableView = tableView;
    _listType  = listType;
    _isCollectionNode = NO;
    _enableSkeletonView = YES;
    _requestArgument = [NSMutableDictionary dictionaryWithDictionary:params];
    _manager = [[TFTableViewManager alloc] initWithTableView:tableView];
    _manager.delegate = self;
    
    [self initListViewPullRefresh];
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
    _batchShouldLoadInFirstPage = YES;
    _delegate  = delegate;
    _tableNode = tableNode;
    _tableView = tableNode.view;
    _listType  = listType;
    _isCollectionNode = NO;
    _enableSkeletonView = YES;
    _requestArgument = [NSMutableDictionary dictionaryWithDictionary:params];
    _manager = [[TFTableViewManager alloc] initWithTableNode:tableNode];
    _manager.delegate = self;
    [self initListViewPullRefresh];
    [self setupDataSource];
    return self;
    
}



- (instancetype)initWithCollectionNode:(ASCollectionNode *)collectionNode
                         listType:(NSInteger)listType
                           params:(NSDictionary *)params
                         delegate:(id)delegate {
    self = [super init];
    if (!self) {
        return nil;
    }
    _batchShouldLoadInFirstPage = YES;
    _delegate  = delegate;
    _collectionNode = collectionNode;
    _collectioView = collectionNode.view;
    _listType  = listType;
    _isCollectionNode = YES;
    _enableSkeletonView = YES;
    _requestArgument = [NSMutableDictionary dictionaryWithDictionary:params];
    _manager = [[TFTableViewManager alloc] initWithCollectionNode:collectionNode];
    _manager.delegate = self;
    [self initListViewPullRefresh];
    [self setupDataSource];
    return self;
    
}



#pragma mark - Public

- (void)startLoading {
    if (_enableSkeletonView) {
        
    }
    [self startLoadingWithParams:_requestArgument];
}


- (void)stopLoading {
    _dataSourceState = TFDataSourceStateFinished;
    [self stopListViewPullRefresh];
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

#pragma mark - 初始化数据加载方法
- (void)setupDataSource {
    _downThresholdY = 200.0;
    _upThresholdY = 25.0;
    NSString *className = [[TFTableViewDataSourceConfig sharedInstance] classNameByListType:_listType];
    if (className) {
        Class class = NSClassFromString(className);
        _tableViewDataManager = [[class alloc] initWithDataSource:self listType:_listType];
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

- (void)initListViewPullRefresh {
    TFTableViewLogDebug(@"%s",__func__);
}

- (void)startListViewPullRefresh {
    TFTableViewLogDebug(@"%s",__func__);
    [self loadDataWithPolicy:TFDataLoadPolicyReload context:nil];
}

- (void)stopListViewPullRefresh {
    TFTableViewLogDebug(@"%s",__func__);
}

#pragma mark - 数据加载核心方法

- (void)loadDataWithPolicy:(TFDataLoadPolicy)loadPolicy context:(ASBatchContext *)context {
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
    //设置操作标示
    _dataSourceState = TFDataSourceStateLoading;
    NSString *requestURL = [[TFTableViewDataSourceConfig sharedInstance] requestURLByListType:_listType];
    _dataRequest = [[TFTableViewDataRequest alloc] initWithRequestURL:requestURL params:_requestArgument];
    _dataRequest.requestArgument    = _requestArgument;
    _dataRequest.cacheTimeInSeconds = _cacheTimeInSeconds;
    NSMutableArray *requestArr = [NSMutableArray arrayWithObject:_dataRequest];
    if (_batchShouldLoadInFirstPage) {
        if (_currentPage==1) {
            [requestArr addObjectsFromArray:_batchRequestArr];
        }
    }
    else {
        [requestArr addObjectsFromArray:_batchRequestArr];
    }
    _dataBatchRequest = [[TFBatchRequest alloc] initWithRequestArray:requestArr];
    
    LoadDataOperation* opeartion = [[LoadDataOperation alloc] initWithRequest:_dataBatchRequest
                                                               dataLoadPolocy:loadPolicy
                                                                firstLoadOver:self.loadCacheDataOver];
    __weak TFTableViewDataSource* wself = self;
    __weak LoadDataOperation* wOperation = opeartion;
    _loadCacheDataOver = YES;
    [opeartion setCompletionBlock:^{
        [wself handleResultData:wOperation.result
                    dataRequest:[wOperation.request.requestArray firstObject]
                 dataLoadPolicy:wOperation.policy
                        context:context
                          error:nil];
    }];
    [self.loadDataOperationQueue addOperation:opeartion];
    
}

#pragma mark 处理返回数据并绘制UI

- (void)handleResultData:(NSDictionary *)result
             dataRequest:(TFRequest *)dataRequest
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
    __block blockDataLoadPolicy = dataLoadPolicy;
    [self.tableViewDataManager reloadView:result
                                    block:^(BOOL finished, id object, NSError *error, NSArray <TFTableViewSection *> *sections)
     {
         typeof(self) strongSelf = weakSelf;
         if (finished) {
             
             if (error) {
                 if (blockDataLoadPolicy == TFDataLoadPolicyNone) {
                     [strongSelf.manager removeAllSections];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(didFinishLoad:object:error:)]) {
                         [strongSelf.delegate didFinishLoad:blockDataLoadPolicy object:object error:error?error:hanldeError];
                     }
                     strongSelf.dataSourceState = TFDataSourceStateFinished;
                     if (_isCollectionNode) {
                         [strongSelf.collectionNode reloadData];
                     }
                     else {
                         [strongSelf.tableView reloadData];
                     }
                 });
                 //数据加载完成
                 if (blockDataLoadPolicy == TFDataLoadPolicyReload) {
                     [strongSelf stopListViewPullRefresh];
                 }
             }
             else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSInteger lastSectionIndex = strongSelf.manager.sections.count - 1;
                     if (blockDataLoadPolicy == TFDataLoadPolicyMore) {
                         
                         if (dataRequest.hasLoadedDataFromCache) {
                             //刷新数据
                             NSInteger totalCount = strongSelf.manager.sections.count;
                             NSInteger replaceCount = sections.count;
                             [strongSelf.manager replaceSectionsInRange:NSMakeRange(totalCount-replaceCount, replaceCount) withSectionsFromArray:sections];
                             if (_isCollectionNode) {
                                 [strongSelf.collectionNode reloadData];
                             }
                             else {
                                 [strongSelf.tableView reloadData];
                             }
                         }
                         else {
                             //加载下一页，移除loading item
                             [strongSelf.manager removeSectionsAtIndexes:[NSIndexSet indexSetWithIndex:lastSectionIndex]];
                             if (_isCollectionNode) {
                                 [strongSelf.collectionNode beginUpdates];
                                 [strongSelf.collectionNode deleteSections:[NSIndexSet indexSetWithIndex:lastSectionIndex]];
                                 [strongSelf addNewAndLoadingSectionsWith:sections];
                                 [strongSelf.collectionNode endUpdatesAnimated:YES];
                                 [weakSelf _loadNewDataAfterLoadedCacheObjectWithRequest:dataRequest dataLoadPolicy:blockDataLoadPolicy context:context];
                             }
                             else {
                                 [strongSelf.tableView beginUpdates];
                                 [strongSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:lastSectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                                 //重新载入新的section和loadsection
                                 [strongSelf addNewAndLoadingSectionsWith:sections];
                                 if (strongSelf.tableNode) {
                                     
                                     [strongSelf.tableNode.view endUpdatesAnimated:YES completion:nil];
                                     [weakSelf _loadNewDataAfterLoadedCacheObjectWithRequest:dataRequest dataLoadPolicy:blockDataLoadPolicy context:context];
                                 }
                                 else {
                                     [strongSelf.tableView endUpdates];
                                     //请求新的数据
                                     [weakSelf _loadNewDataAfterLoadedCacheObjectWithRequest:dataRequest dataLoadPolicy:blockDataLoadPolicy context:context];
                                 }
                             }
                           
                             [context completeBatchFetching:YES];
                         }
                     }
                     else {
                         if (strongSelf.collectionNode) {
                             //support for ascollectionnode
                             ASDisplayNode *snapshotNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull{
                                 return [strongSelf.collectionNode.view snapshotViewAfterScreenUpdates:NO];
                             }];
                             [strongSelf.collectionNode.supernode insertSubnode:snapshotNode aboveSubnode:strongSelf.collectionNode];
                             [strongSelf.collectionNode beginUpdates];
                             //重新加载列表数据
                             NSInteger sectionCount = strongSelf.manager.sections.count;
                             [strongSelf.manager removeAllSections];
                             [strongSelf.collectionNode deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sectionCount)]];
                             
                             //重新载入新的section和loadsection
                             [strongSelf addNewAndLoadingSectionsWith:sections];
                             [strongSelf.collectionNode endUpdatesAnimated:NO completion:^(BOOL completed) {
                                 [UIView animateWithDuration:0.75 animations:^{
                                     snapshotNode.alpha = 0;
                                 } completion:^(BOOL finished) {
                                     [snapshotNode removeFromSupernode];
                                     
                                 }];
                             }];
                             //请求新的数据
                             [weakSelf _loadNewDataAfterLoadedCacheObjectWithRequest:dataRequest dataLoadPolicy:blockDataLoadPolicy context:context];
                         }
                         else if (strongSelf.tableNode) {
                             //support for astablenode
                             UIView *snapshot = [strongSelf.tableView snapshotViewAfterScreenUpdates:NO];
                             [strongSelf.tableView.superview insertSubview:snapshot aboveSubview:strongSelf.tableView];
                             [strongSelf.tableView beginUpdates];
                             //重新加载列表数据
                             NSInteger sectionCount = strongSelf.manager.sections.count;
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
                             //请求新的数据
                             [weakSelf _loadNewDataAfterLoadedCacheObjectWithRequest:dataRequest dataLoadPolicy:blockDataLoadPolicy context:context];
                         }
                         else if (strongSelf.tableView) {
                             //support for uitableview
                             [strongSelf.tableView beginUpdates];
                             //重新加载列表数据
                             NSInteger sectionCount = strongSelf.manager.sections.count;
                             [strongSelf.manager removeAllSections];
                             [strongSelf.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sectionCount)]
                                                 withRowAnimation:UITableViewRowAnimationFade];
                             //重新载入新的section和loadsection
                             [strongSelf addNewAndLoadingSectionsWith:sections];
                             [strongSelf.tableView endUpdates];
                             //请求新的数据
                             [weakSelf _loadNewDataAfterLoadedCacheObjectWithRequest:dataRequest dataLoadPolicy:blockDataLoadPolicy context:context];
                         }
                     }
                     //数据加载完成
                     if (blockDataLoadPolicy == TFDataLoadPolicyReload) {
                         [strongSelf stopListViewPullRefresh];
                     }
                     if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(didFinishLoad:object:error:)]) {
                         [strongSelf.delegate didFinishLoad:dataLoadPolicy object:object error:error?error:hanldeError];
                     }
                     strongSelf.dataSourceState = TFDataSourceStateFinished;
                 });
             }
         }
     }];
}

- (void)addNewAndLoadingSectionsWith:(NSArray *)sections {
    NSInteger rangelocation = self.manager.sections.count;
    [self.manager addSectionsFromArray:sections];
    NSInteger rangelength = 0;
    rangelength += sections.count;
    //需要在主线程执行
    if (_currentPage < _totalPage) {
        //存在下一页数据，在列表尾部追加loading item
        TFTableViewSection *section = [TFTableViewSection section];
        //loading item
        [section addItem:[TFLoadingTableViewItem itemWithModel:NSLocalizedString(@"正在加载...", nil)]];
        [self.manager addSection:section];
        rangelength +=1;
    }
    if (_isCollectionNode) {
        [self.collectionNode insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(rangelocation, rangelength)]];
    }
    else {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(rangelocation, rangelength)]
                      withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

- (void)_loadNewDataAfterLoadedCacheObjectWithRequest:(TFRequest *)request dataLoadPolicy:(TFDataLoadPolicy)dataLoadPolicy context:(ASBatchContext *)context {
    if (request.hasLoadedDataFromCache&&request.isDataFromCache) {
        typeof(self) __weak weakSelf = self;
        [request startWithoutCacheCompletionBlockWithSuccess:^(__kindof TFRequest *request) {
            [weakSelf handleResultData:request.responseObject dataRequest:request dataLoadPolicy:dataLoadPolicy context:context error:request.error];
        } failure:^(__kindof TFRequest *request) {
            [weakSelf handleResultData:request.responseObject dataRequest:request dataLoadPolicy:dataLoadPolicy context:context error:request.error];
        }];
    }
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
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
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


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.delegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:YES];
    }
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

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.delegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.delegate scrollViewShouldScrollToTop:scrollView];
    }
    if ([self.delegate respondsToSelector:@selector(scrollFullScreenScrollViewDidEndDraggingScrollDown)]) {
        [self.delegate scrollFullScreenScrollViewDidEndDraggingScrollDown];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.delegate scrollViewDidScrollToTop:scrollView];
    }
}

- (void)dealloc {
    _manager.delegate = nil;
    _tableView = nil;
    _manager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
