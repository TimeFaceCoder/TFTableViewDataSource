//
//  TFTableViewDataSource.h
//  TFTableViewDataSource
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TFTableViewManager/TFTableViewManager.h>
#import "TFTableViewDataRequest.h"

@class TFTableViewItem;
@class ASTableView;

/**
 *  数据加载方式
 */
typedef NS_ENUM(NSInteger, TFDataLoadPolicy) {
    /**
     *  正常加载
     */
    TFDataLoadPolicyNone      = 0,
    /**
     *  加载下一页
     */
    TFDataLoadPolicyMore      = 1,
    /**
     *  重新加载
     */
    TFDataLoadPolicyReload    = 2,
    /**
     *  从缓存加载
     */
    TFDataLoadPolicyCache     = 3,
};

/**
 *  数据加载状态
 */
typedef NS_ENUM(NSInteger, TFDataSourceState) {
    /**
     *  默认状态
     */
    TFDataSourceStateNone      = 0,
    /**
     *  正在加载状态
     */
    TFDataSourceStateLoading   = 1,
    /**
     *  加载完成状态
     */
    TFDataSourceStateFinished  = 2,
    /**
     *  加载出错
     */
    TFDataSourceStateLoadError = 3,
};

/**
 *  tableview滚动方向
 */
typedef NS_ENUM(NSInteger, TFTableViewScrollDirection) {
    /**
     *  静止
     */
    TFTableViewScrollDirectionNone  = 0,
    /**
     *  向上
     */
    TFTableViewScrollDirectionUp    = 1,
    /**
     *  向下
     */
    TFTableViewScrollDirectionDown  = 2,
    /**
     *  向左
     */
    TFTableViewScrollDirectionLeft  = 3,
    /**
     *  向右
     */
    TFTableViewScrollDirectionRight = 4,
};

@protocol TFTableViewDataSourceDelegate <TFTableViewManagerDelegate>

@required
/**
 *  列表及其控件点击事件回调
 *
 *  @param item
 *  @param actionType 事件类型
 */
- (void)actionOnView:(TFTableViewItem *)item actionType:(NSInteger)actionType;

/**
 *  加载完成
 *
 *  @param loadPolicy 加载类型
 *  @param object     返回数据
 *  @param error      错误
 */
- (void)didFinishLoad:(TFDataLoadPolicy)loadPolicy object:(id)object error:(NSError *)error;

@optional
/**
 *  是否显示下拉刷新
 *
 *  @return a bool value.
 */
- (BOOL)showPullRefresh;

/**
 *  scrollView正在滚动
 *
 *  @param scrollView 当前的scrollView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

/**
 *  scrollView向上滚动
 *
 *  @param deltaY 向上滚动偏移量
 */
- (void)scrollViewDidScrollUp:(CGFloat)deltaY;

/**
 *  scrollView向下滚动
 *
 *  @param deltaY 向下滚动偏移量
 */
- (void)scrollViewDidScrollDown:(CGFloat)deltaY;

/**
 *  scrollView停止向上拖动
 */
- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp;

/**
 *  scrollView停止向下拖动
 */
- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown;

/**
 *  scrollView停止拖动将要停止减速
 *
 *  @param scrollView 当前的scrollView
 *  @param decelerate 是否减速
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end

@interface TFTableViewDataSource : NSObject <UITableViewDelegate>

/**
 *  @brief the deletegate of data source to handle the actions of tableview delegate.
 */
@property (nonatomic ,weak) id<TFTableViewDataSourceDelegate> delegate;

/**
 *  @brief change the model to item.
 */
@property (nonatomic ,strong ,readonly ,getter = manager) TFTableViewManager *manager;

/**
 *  @brief 当前的tableview
 */
@property (nonatomic ,weak) UITableView *tableView;

/**
 *  @brief 当前的tablenode
 */
@property (nonatomic ,weak) ASTableNode *tableNode;

/**
 *  网络数据加载工具
 */
@property (nonatomic , strong, readonly) TFTableViewDataRequest *dataRequest;

/**
 *  @brief 加载状态
 */
@property (nonatomic ,assign) TFDataSourceState dataSourceState;

/**
 *  @brief 总页数
 */
@property (nonatomic ,assign) NSInteger totalPage;

/**
 *  @brief 当前页码
 */
@property (nonatomic ,assign) NSInteger currentPage;

/**
 *  @brief 列表类型
 */
@property (nonatomic ,assign) NSInteger listType;

/**
 *  列表数据缓存时间
 */
@property (nonatomic ,assign) NSInteger cacheTimeInSeconds;


/**
 *  @brief 当前pageSize
 */
@property (nonatomic, assign) NSInteger pageSize;

/**
 *  初始化方法
 *
 *  @param tableView the display tableView
 *  @param listType  list type of the tableView
 *  @param params    params dictionary.
 *  @param delegate  the delegate of data source.
 *
 *  @return a new data source.
 */
- (instancetype)initWithTableView:(UITableView *)tableView
                         listType:(NSInteger)listType
                           params:(NSDictionary *)params
                         delegate:(id /*<TFTableViewDataSourceDelegate>*/)delegate;

/**
 *  初始化方法
 *
 *  @param tableNode the display tableNode
 *  @param listType  list type of the tableNode
 *  @param params    params dictionary.
 *  @param delegate  the delegate of data source.
 *
 *  @return a new data source.
 */
- (instancetype)initWithTableNode:(ASTableNode *)tableNode
                         listType:(NSInteger)listType
                           params:(NSDictionary *)params
                         delegate:(id /*<TFTableViewDataSourceDelegate>*/)delegate;

/**
 *  开始加载数据
 */
- (void)startLoading;

/**
 *  开始加载列表数据
 *
 *  @param params 请求参数
 */
- (void)startLoadingWithParams:(NSDictionary *)params;

/**
 *  停止加载
 */
- (void)stopLoading;

/**
 *  刷新指定Cell
 *
 *  @param actionType 刷新动作
 *  @param identifier Cell唯一标示
 */
- (void)refreshCell:(NSInteger)actionType identifier:(NSString *)identifier;

/**
 *  初始化下拉刷新
 */
- (void)initTableViewPullRefresh;

/**
 *  开始下拉刷新
 */
- (void)startTableViewPullRefresh;

/**
 *  停止下拉刷新
 */
- (void)stopTableViewPullRefresh;

@end
