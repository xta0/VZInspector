//
//  VZInspectorCrashView.h
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspectorView.h"

@protocol VZInspectorCrashViewCallBackProtocol  <NSObject>

@optional
- (void)onBack;


@end


@interface VZInspectorCrashView : VZInspectorView

@property(nonatomic,weak) id<VZInspectorCrashViewCallBackProtocol> delegate;
@property(nonatomic,strong) NSString* path;


@end
