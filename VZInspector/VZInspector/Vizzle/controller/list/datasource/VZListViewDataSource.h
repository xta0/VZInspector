//
//  VZListViewDataSource.h
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VZHTTPListModel,VZListViewController,VZListItem;

@protocol VZListViewDataSource<UITableViewDataSource>

@required
/**
 * 指定cell的类型
 */
- (Class)cellClassForItem:(VZListItem*)item AtIndex:(NSIndexPath *)indexPath;
/**
 *指定返回的item
 */
- (VZListItem*)itemForCellAtIndexPath:(NSIndexPath*)indexPath;
/**
 *绑定items和model
 */
- (void)tableViewControllerDidLoadModel:(VZHTTPListModel*)model ForSection:(NSInteger)section;

@end

@interface VZListViewDataSource : NSObject<VZListViewDataSource>
/**
 * remote controller
 */
@property(nonatomic,weak)  VZListViewController*  controller;
/**
 * <k:NSArray v:section>
 * section到列表数据的映射
 */
@property(nonatomic,strong)  NSDictionary* itemsForSection;
/**
 * <k:NSInterger v:section>
 * section到列表数据总数的映射
 */
@property(nonatomic,strong)  NSDictionary* totalCountForSection;

/**
 *  根据section为datasource赋值
 *
 *  @param items 被赋值的数据
 *  @param n     section
 */
- (void)setItems:(NSArray*)items ForSection:(NSInteger)n; //增

/**
 *  获取datasource中的数据
 *
 *  @param n 获取的section
 */
- (NSArray *)ItemsForSection:(int)section;

/**
 *  清除datasource中section部分的object
 *
 *  @param n 查找的的section
 *  @object  待清楚的object
 */
- (BOOL)removeItem:(VZListItem* )item FromSection:(NSInteger)n; //删
/**
 *  清除datasource中的数据
 *
 *  @param n 待清除的section
 */
- (void)removeItemsFromSection:(NSInteger)n;
/**
 *  清除datasource所有数据
 */
- (void)removeAllItems;

@end
