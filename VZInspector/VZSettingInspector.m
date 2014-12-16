//
//  VZSettingInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-12-16.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZSettingInspector.h"

@implementation VZSettingInspector

+ (VZSettingInspector* )sharedInstance
{
    static VZSettingInspector* instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [VZSettingInspector new];
    });
    
    return instance;
}

@end
