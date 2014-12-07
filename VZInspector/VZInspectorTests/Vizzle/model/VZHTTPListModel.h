//
//  VZHTTPListModel.h
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZHTTPModel.h"

/**
 *  列表model的翻页模式
 */
typedef NS_OPTIONS(NSUInteger, VZPageMode) {
    /**
     *  有数据回来就自动翻页，否则停止翻页
     */
    VZPageModePageDefault        = 0,
    /**
     *  有数据回来，如果数量小于pagesize，则停止翻页
     *  有数据回来，且数量等于pagesize，则自动翻页
     *  没有数据回来，则停止翻页
     */
    VZPageModePageReturnCount    = 1,
    /**
     *  翻页依据自定义的totalCount，不依赖pagesize
     */
    VZPageModePageCustomize      = 2
};

@protocol VZHTTPListModel <VZHTTPModel>

@optional
- (NSMutableArray* )responseObjects:(id)JSON;

@end

@interface VZHTTPListModel : VZHTTPModel<VZHTTPListModel>

/**
 *  列表是否可以翻页
 */
@property(nonatomic,assign,readonly) BOOL hasMore;
/**
 *  分页模式，默认是 default
 */
@property (nonatomic, assign) VZPageMode pageMode;

/**
 * 分页当前页数
 */
@property(nonatomic, assign) NSInteger currentPageIndex;

/**
 * 列表总条数，根据 pageMode
 */
@property(nonatomic, assign) NSInteger totalCount;

/**
 *  分页个数，默认20
 */
@property(nonatomic, assign) NSInteger pageSize;
/**
 *  对应的section
 */
@property(nonatomic, assign) NSInteger sectionNumber;
/**
 *  数据
 */
@property(nonatomic,strong) NSMutableArray* objects;

/**
 *  model加载更多的请求
 */
- (void)loadMore;

@end
