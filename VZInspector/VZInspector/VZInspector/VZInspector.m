//
//  VZInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import "VZInspector.h"
#import "VZInspectorOverlay.h"
#import "VZInspectorWindow.h"
#import "VZHeapInspector.h"
#import "VZCrashInspector.h"
#import "VZOverviewInspector.h"

@implementation VZInspector

+ (void)showOnStatusBar
{
    [VZInspectorOverlay show];
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
    [VZHeapInspector setClassPrefixName:name];
}

+ (void)setShouldHandleCrash:(BOOL)b
{
    if (b) {
        [[VZCrashInspector sharedInstance] install];
    }
    
}
+ (void)setObserveCallback:(NSString* (^)(void)) callback;
{
    [VZOverviewInspector sharedInstance].observingCallback = callback;
}
@end
