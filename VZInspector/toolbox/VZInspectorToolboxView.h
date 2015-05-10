//
//  VZToolboxView.h
//  VZInspector
//
//  Created by lingwan on 15/4/16.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import "VZInspectorView.h"

typedef NS_ENUM(NSInteger, VZToolBoxType)
{
    kNetworkLogs = 0,
    kHeaps ,
    kBorder,
    kViewClass,
    kCrashLogs,
    kSandBox,
    kGrids,
    kMemoryWarningOn,
    kMemoryWarningOff,
    kDevice
};

@protocol VZInspectorToolboxViewCallback <NSObject>

- (void)onToolBoxViewClicked:(VZToolBoxType)type;

@end

@interface VZInspectorToolboxView : VZInspectorView

@property(nonatomic,assign,readonly) VZToolBoxType type;
@property(nonatomic,weak) id<VZInspectorToolboxViewCallback> callback;

@end
