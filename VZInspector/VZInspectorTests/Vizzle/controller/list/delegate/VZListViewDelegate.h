//
//  VZListViewDelegate.h
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VZListViewController;
@protocol VZListViewDelegate <UITableViewDelegate>
@end

/**
 第三方下拉刷新的view实现这四个方法
 */
@protocol VZListPullToRefreshViewDelegate <NSObject>

@required
- (void)scrollviewDidScroll:(UIScrollView*)scrollview;
- (void)scrollviewDidEndDragging:(UIScrollView*)scrollview;
- (void)startRefreshing;
- (void)stopRefreshing;
@end


@interface VZListViewDelegate : NSObject<VZListViewDelegate>

/**
 * a weak reference to view controller
 */
@property (nonatomic, weak) VZListViewController* controller;
/**
 custom pull-refresh view
 */
@property(nonatomic,strong) id<VZListPullToRefreshViewDelegate> pullRefreshView;
/**
 begin & end pull refresh
 */
- (void)beginRefreshing;
- (void)endRefreshing;


@end
