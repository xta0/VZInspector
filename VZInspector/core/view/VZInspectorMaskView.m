//
//  VZInspectorMaskView.m
//  APInspector
//
//  Created by 净枫 on 16/6/14.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorMaskView.h"
#import "VZDefine.h"
#import <UIKit/UIKit.h>

@implementation VZInspectorMaskView{
    BOOL _showing;
    CGRect _contentFrame;
    CGRect _rootFrame ;

}

- (instancetype)initWithFrame:(CGRect)frame rootView:(UIView *)rootView{
    if(self = [super init]){
        _contentFrame = frame;
        _rootFrame = rootView.frame;
        _contentView = [[UIView alloc]initWithFrame:frame];
        _backgroudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _rootFrame.size.width, _rootFrame.size.height)];
        _backgroudView.backgroundColor = VZ_RGBA(0x000000, 0.68);
        
        _contentView.center = CGPointMake(_rootFrame.size.width/2, _rootFrame.size.height/2);
        _contentFrame = _contentView.frame;
        
        [_backgroudView addSubview:_contentView];
        
        [_backgroudView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundView)]];
        
        _rootView = rootView;
        _showing = NO;
        _canceledOnTouchOutside = NO;
        [self layoutMaskviews];
    }
    
    return self;
}

- (void)setCanceledOnTouchOutside:(BOOL)canceledOnTouchOutside{
    if(canceledOnTouchOutside){
        _backgroudView.userInteractionEnabled = YES;
    }else{
        _backgroudView.userInteractionEnabled = NO;
    }
    _canceledOnTouchOutside = canceledOnTouchOutside;
}

- (void)setBackgroudView:(UIView *)backgroudView{
    if(_backgroudView){
        [_contentView removeFromSuperview];
        [_backgroudView removeFromSuperview];
    }
    _backgroudView = backgroudView;
    [_backgroudView addSubview:_contentView];
}

- (void)tapBackgroundView{
    if(_canceledOnTouchOutside){
        if([self.delegate respondsToSelector:@selector(cancleMaskView)]){
            [self.delegate cancleMaskView];
        }
    }
}

- (void)hideMaskView{
    if (_rootView && _backgroudView) {
        
        [UIView animateWithDuration:0.3 animations:^{
            _backgroudView.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            [_backgroudView removeFromSuperview];
            _showing = NO;
        }];
    }
}

- (void)showMaskView{
    if(_rootView && _backgroudView){
        [_backgroudView removeFromSuperview];
        _backgroudView.alpha = 1;
        [_rootView addSubview:_backgroudView];
        [_rootView bringSubviewToFront:_backgroudView];
        _showing = YES;
    }
}

- (void)removeFromSuperview{
    if(_rootView && _backgroudView){
        [_backgroudView removeFromSuperview];
        _showing = NO;
    }
}

- (BOOL)isShowing{
    return _showing;
}

- (void)layoutMaskviews{
    //subClass todo
}

@end
