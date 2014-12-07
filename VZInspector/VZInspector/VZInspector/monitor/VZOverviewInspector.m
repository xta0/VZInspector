//
//  VZOverviewInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-12-6.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import "VZOverviewInspector.h"


@interface VZOverviewInspector()

@end

@implementation VZOverviewInspector

+ (VZOverviewInspector* )sharedInstance
{
    static VZOverviewInspector* instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [VZOverviewInspector new];
    });
    
    return instance;
}

@end
