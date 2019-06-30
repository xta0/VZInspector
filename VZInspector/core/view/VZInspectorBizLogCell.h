//
//  Copyright © 2016年 Vizlab. All rights reserved.
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
