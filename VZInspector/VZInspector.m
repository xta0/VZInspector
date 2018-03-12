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
#import "VZCrashInspector.h"
#import "VZOverviewInspector.h"
#import "VZSettingInspector.h"
#import "VZLogInspector.h"
#import "VZNetworkObserver.h"
#import "VZBorderInspector.h"
#import "VZInspectorToolboxView.h"
#import "VZDevice.h"
#import "VZInspectorMermoryManager.h"

@implementation VZInspector

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOnStatusBar) name:UIApplicationDidFinishLaunchingNotification object:nil];
    
    [[VZInspectorMermoryManager sharedInstance] startTrackingIfNeed];
    
    [self addObserveCallback:^NSString *{
        return [[VZDevice infoArray] componentsJoinedByString:@"\n"];
    }];
}

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
//    NSData *data = [NSData dataWithContentsOfFile:@"/Users/lingwan/ios-phone-o2o-debug/APInspector/aa.png"];
//    NSUInteger len = [data length];
//    Byte *byteData = (Byte*)malloc(len);
//    memcpy(byteData, [data bytes], len);
//
//    for (int i=0; i<len; i++) {
//        printf("0x%x,",byteData[i]);
//    }
    
    [VZInspectorWindow sharedInstance].hidden = NO;
    [VZInspectorOverlay hide];
}

+ (void)hide
{
    [VZInspectorWindow sharedInstance].hidden = YES;
    [VZInspectorOverlay show];
}

+ (void)setClassPrefixName:(NSString *)name
{
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

+ (void)addObserveCallback:(NSString* (^)(void)) callback;
{
    [[VZOverviewInspector sharedInstance].observingCallbacks addObject:callback];
}

+ (NSMutableArray *)_addtionTools {
    static NSMutableArray *additionTools;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        additionTools = [NSMutableArray array];
    });
    return additionTools;
}

+ (NSArray *)additionTools {
    return [self _addtionTools];
}

+ (void)addToolItem:(VZInspectorToolItem *)toolItem {
    [[self _addtionTools] addObject:toolItem];
}

+ (void)addDashboardSwitch:(NSString* )type Highlight:(BOOL)highligh Callback:(void(^)(void))callback{

    [VZSettingInspector  addAPIEnvButtonWithName:type Selected:highligh Callback:callback];
}


@end
