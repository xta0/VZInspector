//
//  VZOverviewInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-12-6.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZOverviewInspector.h"


@interface VZOverviewInspector()

@end

@implementation VZOverviewInspector

- (instancetype)init {
    if (self = [super init]) {
        _observingCallbacks = [NSMutableArray array];
    }
    return self;
}

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
