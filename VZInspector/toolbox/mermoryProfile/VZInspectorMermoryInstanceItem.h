//
//  VZInspectorMermoryInstanceItem.h
//  APInspector
//
//  Created by 净枫 on 2016/12/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorBizLogItem.h"

@interface VZInspectorMermoryInstanceItem : VZInspectorBizLogItem

@property (nonatomic, strong)NSString *className;

@property (nonatomic, weak) id object;

@end
