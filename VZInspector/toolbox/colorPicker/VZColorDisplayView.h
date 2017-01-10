//
//  VZColorDisplayView.h
//  APInspector
//
//  Created by pep on 2016/12/3.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VZColorDisplayView;

@protocol VZColorDisplayViewDelegate <NSObject>

- (void)displayView:(VZColorDisplayView *)displayView colorDidUpdate:(UIColor *)color;

@end

//宽高要设置成奇数
@interface VZColorDisplayView : UIView

+ (instancetype)displayViewWithRadius:(CGFloat)r scale:(NSUInteger)scale;


@property (nonatomic, assign) NSUInteger scale; //放大倍数，>=1
@property (nonatomic, weak) id<VZColorDisplayViewDelegate> delegate;

- (void)update;

@end
