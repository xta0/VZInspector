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

@implementation VZInspector

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

@end
