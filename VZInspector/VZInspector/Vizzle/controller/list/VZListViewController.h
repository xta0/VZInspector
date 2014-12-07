//
//  VZListViewController.h
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZViewController.h"

@class VZHTTPListModel;
@class VZListViewDataSource;
@class VZListViewDelegate;

@interface VZListViewController : VZViewController

/**
 *  tablview
 */
@property(nonatomic,strong) UITableView* tableView;
/**
 *  tablview的delegate和datasource
 */
@property(nonatomic,strong) VZListViewDataSource* dataSource;
@property(nonatomic,strong) VZListViewDelegate*   delegate;
/**
 *  keyModel:@REQUIRED : 用来翻页的model，必须不为空
 */
@property(nonatomic,strong) VZHTTPListModel* keyModel;
/**
 *  自动翻页的标志位
 */
@property(nonatomic,assign) BOOL loadmoreAutomatically;
/**
 *  是否需要翻页
 */
@property(nonatomic,assign) BOOL bNeedLoadMore;
/**
 *  是否需要下拉刷新
 */
@property(nonatomic,assign) BOOL bNeedPullRefresh;
/**
 *  model reload的时候是否清空当前数据,默认为YES
 */
@property(nonatomic,assign) BOOL clearItemsWhenModelReload;

/**
 *  加载更多Model数据，例如下一页
 */
- (void)loadMore;
/**
 * 加载某个section对应的model
 */
- (void)loadModelForSection:(NSInteger)section;
/**
 *  根据model的key来加载model
 *
 *  适用：多个model对应一个section，tab切换的场景
 *
 *  v = VZMV* => 1.1
 *
 *  @param key
 */
- (void)loadModelByKey:(NSString* )key;

/**
 * 显示下拉刷新
 */
- (void)beginRefreshing;
/**
 * 隐藏下拉刷新
 */
- (void)endRefreshing;

@end

@interface VZListViewController(UITableView)

/**
 * tableview cell的点击事件
 */
- (void)tableView:(UITableView *)tableView  didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 * tableview cell的UI组件点击，bunlde中存放了自定义的参数
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath component:(NSDictionary*)bundle;
/**
 * tableview cell的编辑事件
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 * scrollview的滚动回调
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
/**
 * scrollview拖拽释放后的回调
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
/**
 * scrollview拖拽事件回调
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView ;
/**
 * scrollview停止滚动回调
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView ;

@end

@interface VZListViewController(FooterView)

/**
 *  展示没有数据的footerview状态
 *
 *  @param model 请求完成的model
 */
- (void)showNoResult:(VZHTTPListModel *)model;
/**
 *  展示model滚动完成的footerview状态
 *
 *  @param model 请求完成的model
 */
- (void)showComplete:(VZHTTPListModel *)model;
/**
 *  展示loadmore的footerview状态，如果loadmoreAutomatically则不会显示这个状态
 */
- (void)showLoadMoreFooterView;

@end