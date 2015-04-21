//
//  VZInspectController.h
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VZInspectController : UIViewController

@property(nonatomic,strong,readonly) UIView* currentView;
@property(nonatomic,assign,readonly) NSInteger currentIndex;

- (void)start;
- (void)stop;
- (BOOL)canTouchPassThrough:(CGPoint)pt;

@end
