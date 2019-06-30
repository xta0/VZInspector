//
//  Copyright © 2016年 Vizlab. All rights reserved.
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
