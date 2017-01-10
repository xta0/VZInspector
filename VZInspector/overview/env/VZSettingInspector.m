//
//  VZSettingInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-12-16.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZSettingInspector.h"

@implementation VZSettingInspector
{
    NSMutableArray* _btns;
    NSMutableArray* _switches;
}

+ (VZSettingInspector* )sharedInstance
{
    static VZSettingInspector* instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [VZSettingInspector new];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _btns     = [[NSMutableArray alloc]initWithCapacity:3];
        _switches = [[NSMutableArray alloc]initWithCapacity:3];
        
    }
    return self;
}

+ (NSArray* )currentAPIEnvButtons
{
    return [[VZSettingInspector sharedInstance] -> _btns copy];
}

+ (NSArray* )currentAPIEnvSwitches
{
    return [[VZSettingInspector sharedInstance] -> _switches copy];
}

+ (void)addAPIEnvButtonWithName:(NSString* )type Selected:(BOOL)selected Callback:(vz_api_env_callback)callback{
    
    if (type && callback) {
        [[VZSettingInspector sharedInstance] -> _btns addObject:@{type:@[callback,@(selected)]}];
    }
    
}

+ (void)addAPIEnvSwitchWithName:(NSString *)type Selected:(BOOL)selected Callback:(vz_api_env_switch_callback)callback{
    
    if (type && callback) {
        [[VZSettingInspector sharedInstance] -> _switches addObject:@{type:@[callback,@(selected)]}];
    }

}


@end
