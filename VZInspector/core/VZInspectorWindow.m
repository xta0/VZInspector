//
//  VZInspectorWindow.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspectorWindow.h"
#import "VZInspectController.h"

@interface VZInspectorWindow()

@property(nonatomic,strong) VZInspectController* debuggerVC;

@end

@implementation VZInspectorWindow


+ (instancetype)sharedInstance
{
    static VZInspectorWindow* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VZInspectorWindow alloc]init];
    });
    return instance;
    
}

+ (VZInspectController *)sharedController {
    return [[self sharedInstance] debuggerVC];
}

- (id)init
{
    CGRect screenBound = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:screenBound];
    if (self)
    {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        //self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        self.hidden = YES;
        self.windowLevel = UIWindowLevelStatusBar + 200;
        self.userInteractionEnabled = NO;
        
        self.debuggerVC = [VZInspectController new];
        self.rootViewController = self.debuggerVC;
        [self addSubview:self.debuggerVC.view];
        
    }
    return self;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    if ( self.hidden )
    {
        [self.debuggerVC stop];
    }
    else
    {
        [self.debuggerVC start];
    }
}


- (UIView* )hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint pt = [self convertPoint:point toView:self.debuggerVC.view];
    
    if (self.debuggerVC.presentedViewController) {
        for (int i = self.subviews.count - 1; i >= 0; i --) {
            UIView *subview = self.subviews[i];
            CGPoint convertedPoint = [subview convertPoint:point fromView:self];
            UIView *hited = [subview hitTest:convertedPoint withEvent:event];
            if (hited) {
                return hited;
            }
        }
    }
    if ([self.debuggerVC canTouchPassThrough:pt]) {
        return [super hitTest:point withEvent:event];
    }
    else
        return [self.debuggerVC.view hitTest:point withEvent:event];
    // return self.debuggerVC.view;
}




@end
