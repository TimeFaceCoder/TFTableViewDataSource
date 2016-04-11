//
//  TFTableViewDataSource.h
//  TFTableViewDataSource
//
//  Created by Melvin on 3/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MYTableViewManager/MYTableViewManager.h>


@class MYTableViewManager;
@class TFTableViewItem;
@class ASTableView;

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

typedef NS_ENUM(NSInteger, TFTableViewScrollDirection) {
    TFTableViewScrollDirectionNone  = 0,
    TFTableViewScrollDirectionUp    = 1,
    TFTableViewScrollDirectionDown  = 2,
    TFTableViewScrollDirectionLeft  = 3,
    TFTableViewScrollDirectionRight = 4,
};

@protocol TFTableViewDataSourceDelegate <NSObject>

@required
/**
 *  列表及其控件点击事件回调
 *
 *  @param item
 *  @param actionType 事件类型
 */
- (void)actionOnView:(TFTableViewItem *)item actionType:(NSInteger)actionType;
/**
 *  开始加载
 */
- (void)didStartLoad;
/**
 *  加载完成
 *
 *  @param loadPolicy 加载类型
 *  @param object     返回数据
 *  @param error      错误
 */
- (void)didFinishLoad:(TFDataLoadPolicy)loadPolicy object:(id)object error:(NSError *)error;

@optional


- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)scrollViewDidScrollUp:(CGFloat)deltaY;

- (void)scrollViewDidScrollDown:(CGFloat)deltaY;

- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp;

- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(ASTableView *)tableView willDisplayNodeForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(ASTableView *)tableView didEndDisplayingNode:(ASCellNode *)node forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TFTableViewDataSource : NSObject

@property (nonatomic ,weak) id<TFTableViewDataSourceDelegate> delegate;
@property (nonatomic ,strong ,readonly ,getter = manager) MYTableViewManager *manager;
@property (nonatomic ,weak) ASTableView *tableView;
@property (nonatomic ,assign) TFDataSourceState dataSourceState;
/**
 *  总页数
 */
@property (nonatomic ,assign) NSInteger totalPage;
/**
 *  当前页码
 */
@property (nonatomic ,assign) NSInteger currentPage;

@property (nonatomic ,assign) NSInteger listType;
/**
 *  列表数据缓存时间
 */
@property (nonatomic ,assign) NSInteger cacheTimeInSeconds;


- (instancetype)initWithTableView:(ASTableView *)tableView
                         listType:(NSInteger)listType
                           params:(NSDictionary *)params
                         delegate:(id /*<TFTableViewDataSourceDelegate>*/)delegate;

- (void)startLoading;
/**
 *  开始加载列表数据
 *
 *  @param params GET 请求参数
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

- (void)initTableViewPullRefresh;
- (void)startTableViewPullRefresh;
- (void)stopTableViewPullRefresh;

@end
