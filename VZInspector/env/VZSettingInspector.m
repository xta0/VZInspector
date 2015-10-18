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
    NSMutableArray* _envs;
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
        _envs = [[NSMutableArray alloc]initWithCapacity:3];
        
    }
    return self;
}

+ (NSDictionary* )currentAPIEnvs
{
    return [[VZSettingInspector sharedInstance] -> _envs copy];
}

+ (void)addAPIEnvType:(NSString* )type Callback:(vz_api_env_callback)callback{
    
    if (type && callback) {
        [[VZSettingInspector sharedInstance] -> _envs addObject:@{type:callback}];
    }
    
}


@end
