//
//  VZListItem.h
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZItem.h"

/**
 *  item的类型
 */
typedef NS_ENUM(int, VZListItemType)
{
    /**
     *  默认类型，子类应该继承这个类型
     */
    kItem_Normal  = 0,
    /**
     *  loading类型，默认仅被父类使用
     */
    kItem_Loading = 1,
    /**
     *  错误类型，默认仅被父类使用
     */
    kItem_Error   = 2,
    /**
     *  自定一类型，默认仅被父类使用
     */
    kItem_Customize = 3
};

@interface VZListItem : VZItem

/**
 *  @required
 *  item的index
 */
@property (nonatomic,strong) NSIndexPath* indexPath;
/**
 *  @optional
 *  item的高度，建议在model请求完成后赋值
 */
@property (nonatomic,assign) float    itemHeight;
/**
 *  @optional
 *  item的数据类型
 */
@property (nonatomic,assign) VZListItemType  itemType;

@end
