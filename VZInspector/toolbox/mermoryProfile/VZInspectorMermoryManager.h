//
//  VZInspectorMermoryManager.h
//  APInspector
//
//  Created by 净枫 on 2016/12/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorBizLogManager.h"

@interface VZInspectorMermoryManager : VZInspectorBizLogManager

+ (instancetype)sharedInstance ;

- (void)startTrackingIfNeed;

+ (UIImage *)icon;

@end
