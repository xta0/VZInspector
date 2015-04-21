//
//  NSObject+VZInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "NSObject+VZInspector.h"
#include <objc/runtime.h>


@implementation NSObject (VZInspector)

- (void)setSamplePoints:(NSMutableArray *)samplePoints
{
    objc_setAssociatedObject(self, "samplePoints", samplePoints, OBJC_ASSOCIATION_RETAIN);
}

- (NSString*)samplePoints
{
    return objc_getAssociatedObject(self, "samplePoints");
}

- (void)vz_heartBeat
{
    
}


@end
