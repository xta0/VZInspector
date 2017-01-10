//
//  VZInspectorMermoryItem.h
//  APInspector
//
//  Created by 净枫 on 2016/12/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorBizLogItem.h"

typedef NS_ENUM(NSUInteger , VZInspectorMermoryStatus){
    VZInspectorMermoryStatusUnknown = 0,
    VZInspectorMermoryStatusLeaked,
    VZInspectorMermoryStatusNotLeaked
};

@interface VZInspectorMermoryItem : VZInspectorBizLogItem

@property (nonatomic, strong)NSString *className;

@property (nonatomic, assign)NSInteger objectCount;

@property (nonatomic, assign) VZInspectorMermoryStatus retainCycleStatus;

@property (nonatomic, assign) BOOL isLoading;

@end
