//
//  VZSettingInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-12-16.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^vz_api_env_callback)(void);

@interface VZSettingInspector : NSObject

+ (VZSettingInspector* )sharedInstance;
+ (void)addAPIEnvType:(NSString* )type Callback:(vz_api_env_callback)callback;
+ (NSArray* )currentAPIEnvs;

@end
