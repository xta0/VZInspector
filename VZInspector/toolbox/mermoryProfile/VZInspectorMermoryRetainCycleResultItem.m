//
//  VZInspectorMermoryReatinCycleResultItem.m
//  APInspector
//
//  Created by 净枫 on 2016/12/21.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorMermoryRetainCycleResultItem.h"
#import "VZInspectorMermoryRetainCycleItem.h"

@implementation VZInspectorMermoryRetainCycleResultItem

- (NSMutableArray *)retainCycleDatas{
    if(!_retainCycleDatas){
        _retainCycleDatas = [[NSMutableArray alloc]init];
    }
    return _retainCycleDatas;
}

- (NSString *)retainCycleDescrible{
    if(self.retainCycleDatas.count > 0){
        __block NSMutableString *describle = [[NSMutableString alloc]init];
        NSUInteger count = self.retainCycleDatas.count;
        [self.retainCycleDatas enumerateObjectsUsingBlock:^(VZInspectorMermoryRetainCycleItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
            if([item isKindOfClass:[VZInspectorMermoryRetainCycleItem class]]){
                [describle appendFormat:@"%@(%@) -> " ,item.variableClassName ?:@"" , item.variable?:@""];
                
                if(idx == count -1){
                    [describle appendFormat:@"%@" , item.className?:@""];
                }
                
            }
        }];
        return describle ;
    }
    return nil;
}

@end
