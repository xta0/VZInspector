//
//  VZInspectorMermoryReatinCycleResultItem.h
//  APInspector
//
//  Created by 净枫 on 2016/12/21.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorBizLogItem.h"
#import <UIKit/UIKit.h>

@interface VZInspectorMermoryRetainCycleResultItem : VZInspectorBizLogItem

@property (nonatomic, strong)NSMutableArray *retainCycleDatas;

@property (nonatomic, assign)CGSize describleSize;

- (NSString *)retainCycleDescrible;

@end
