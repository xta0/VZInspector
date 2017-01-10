//
//  VZInspectController.h
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VZInspectorToolboxView;

@interface VZInspectController : UIViewController

@property(nonatomic,strong,readonly) UIView* currentView;
@property(nonatomic,assign,readonly) NSString* currentTab;

@property(nonatomic,strong) VZInspectorToolboxView* toolboxView;
@property(nonatomic,strong) VZInspectorToolboxView* pluginView;

- (void)start;
- (void)stop;
- (BOOL)canTouchPassThrough:(CGPoint)pt;
- (void)onClose;
- (void)transitionToView:(UIView *)view;

@end
