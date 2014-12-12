//
//  VZInspectorOverview.h
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspectorView.h"

@interface VZInspectorOverview : VZInspectorView

- (void)updateGlobalInfo;
- (void)handleRead;
- (void)handleWrite;
- (void)performMemoryWarning:(BOOL)b;

@end
