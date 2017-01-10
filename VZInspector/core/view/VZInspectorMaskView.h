//
//  VZInspectorMaskView.h
//  APInspector
//
//  Created by 净枫 on 16/6/14.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VZInspectorMaskViewCancleDelegate <NSObject>

@optional

- (void)cancleMaskView;

@end

@interface VZInspectorMaskView : UIView

@property (nonatomic, strong) UIView *rootView;

@property (nonatomic, weak) id<VZInspectorMaskViewCancleDelegate> delegate;


/**
 *  背景view
 */
@property (nonatomic, strong) UIView *backgroudView;

/**
 *  内容view
 */
@property (nonatomic, strong) UIView *contentView;


/**
 *  点击内容区外的区域取消蒙层 ，默认为NO;
 */
@property (nonatomic, assign) BOOL canceledOnTouchOutside;


- (instancetype)initWithFrame:(CGRect)frame rootView:(UIView *)rootView ;


/**
 *  蒙层是否正在显示
 *
 */
- (BOOL)isShowing;

/**
 *  隐藏蒙层
 */
- (void)hideMaskView;

/**
 *  显示蒙层
 */
- (void)showMaskView;

/**
 *  开始布局蒙层里面的视图
 */
- (void)layoutMaskviews;

- (void)removeFromSuperview;

@end
