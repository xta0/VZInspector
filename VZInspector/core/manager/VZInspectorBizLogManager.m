//
//  VZInspectorBizLogManager.m
//  APInspector
//
//  Created by 净枫 on 16/6/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorBizLogManager.h"

@interface VZInspectorBizLogManager()<VZInspectorBizLogViewDelegate>

@property (nonatomic, assign) CGRect logViewFrameBeforeDragging;

@end

@implementation VZInspectorBizLogManager{
     BOOL _isShowing;
}

+ (instancetype)sharedInstance {
    static VZInspectorBizLogManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[VZInspectorBizLogManager alloc] init];
    });
    return _manager;
}


- (void)toggle{
    if(_isShowing){
        [self hide];
    }else {
        [self show];
    }
}

- (void)show{
    if(!_isShowing){
        if(self.logView){
            self.logView.delegate = self;
            [[UIApplication sharedApplication].keyWindow addSubview:self.logView];
        }
    }
    _isShowing = YES;
}

- (void)hide{
    if(self.logView){
        [self.logView removeFromSuperview];
        self.logView.delegate = nil;
    }
    _isShowing = NO;
}

- (BOOL)isShowing{
    return _isShowing;
}

- (void)onClickCancleButton{
    //subclass todo
    [self hide];
}

- (void)onClickClearButton{
   // subclass todo
}

- (void)dragLogViewPanGesture:(UIPanGestureRecognizer *)pan {
    if(self.logView){
        switch (pan.state) {
            case UIGestureRecognizerStateBegan:
                self.logViewFrameBeforeDragging = self.logView.frame;
                [self updateToolbarPostionWithDragGesture:pan];
                break;
                
            case UIGestureRecognizerStateChanged:
            case UIGestureRecognizerStateEnded:
                [self updateToolbarPostionWithDragGesture:pan];
                break;
                
            default:
                break;
        }
    }
}


- (void)updateToolbarPostionWithDragGesture:(UIPanGestureRecognizer *)pan {
    
    if(self.logView){
        UIView *superView = self.logView.superview;
        CGPoint translation = [pan translationInView:superView];
        CGRect newlogViewFrame = self.logViewFrameBeforeDragging;
        newlogViewFrame.origin.y += translation.y;
        
        CGFloat maxY = CGRectGetMaxY(superView.bounds) - newlogViewFrame.size.height;
        if (newlogViewFrame.origin.y < 0.0) {
            newlogViewFrame.origin.y = 0.0;
        } else if (newlogViewFrame.origin.y > maxY) {
            newlogViewFrame.origin.y = maxY;
        }
        
        self.logView.frame = newlogViewFrame;
    }
}

@end
