//
//  VZCPUInspector.h
//  VZInspector
//
//  Created by lingwan on 15/4/30.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZCPUInspector : NSObject

+ (instancetype)sharedInstance;
+ (float)cpuUsage;

@end
