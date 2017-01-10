//
//  VZInspectorBizLogCell.h
//  APInspector
//
//  Created by 净枫 on 16/6/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZInspectorBizLogItem.h"

@interface VZInspectorBizLogCell : UITableViewCell

/**
 *  cell的index
 */
@property (nonatomic,strong) NSIndexPath* indexPath;
/**
 *  cell绑定的item数据
 */
@property (nonatomic,strong) VZInspectorBizLogItem* item;


@end
