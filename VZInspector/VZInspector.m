//
//  VZInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspector.h"
#import "VZInspectorOverlay.h"
#import "VZInspectorWindow.h"
#import "VZHeapInspector.h"
#import "VZCrashInspector.h"
#import "VZOverviewInspector.h"
#import "VZSettingInspector.h"
#import "VZLogInspector.h"
#import "VZNetworkObserver.h"
#import "VZBorderInspector.h"
#import "VZInspectorToolboxView.h"

@implementation VZInspector

+ (void)showOnStatusBar
{
    //dispatch to the next runloop
    dispatch_async(dispatch_get_main_queue(), ^{
        [VZInspectorOverlay show];
    });

}

+ (BOOL)isShow
{
    return ![VZInspectorWindow sharedInstance].hidden;
}

+ (void)show
{
    [VZInspectorWindow sharedInstance].hidden = NO;
}

+ (void)hide
{
    [VZInspectorWindow sharedInstance].hidden = YES;
    
}

+ (void)setClassPrefixName:(NSString *)name
{
    [VZHeapInspector   setClassPrefixName:name];
    [VZBorderInspector setViewClassPrefixName:name];
}

+ (void)setShouldHandleCrash:(BOOL)b
{
    if (b) {
        [[VZCrashInspector sharedInstance] install];
    }
    
}

+ (void)setShouldHookNetworkRequest:(BOOL)b
{
    [VZNetworkObserver setEnabled:b];
    [VZNetworkObserver setShouldEnableOnLaunch:b];
}

+ (void)setLogNumbers:(NSUInteger)num
{
    [VZLogInspector setNumberOfLogs:num];
}

+ (void)setObserveCallback:(NSString* (^)(void)) callback;
{
    [VZOverviewInspector sharedInstance].observingCallback = callback;
}


+ (void)addToolWithName:(NSString *)name icon:(NSData *)icon callback:(void (^)(void))callback {
    [VZInspectorToolboxView addToolwithName:name icon:icon callback:callback];
}


+ (void)setDefaultAPIEnvIndex:(NSInteger)index
{
    [VZSettingInspector sharedInstance].defaultEnvIndex = index;
}

+ (void)setDevAPIEnvCallback:(void(^)(void))callback
{
    [VZSettingInspector sharedInstance].apiDevCallback = callback;
}

+ (void)setTestAPIEnvCallback:(void(^)(void))callback
{
    [VZSettingInspector sharedInstance].apiTestCallback = callback;
}

+ (void)setProductionAPIEnvCallback:(void(^)(void))callback
{
    [VZSettingInspector sharedInstance].apiProductionCallback = callback;
}

+ (void)addAPIEnvType:(NSString* )type Callback:(void(^)(void))callback
{
    //todo...
    
}

@end
