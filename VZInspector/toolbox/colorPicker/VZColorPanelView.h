//
//  VZColorPanelView.h
//  APInspector
//
//  Created by pep on 2016/12/3.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VZColorPanelView;

@protocol VZColorPanelViewDelegate <NSObject>

- (void)panelView:(VZColorPanelView *)panelView ratioDidChange:(NSInteger )ratio;

@end

@interface VZColorPanelView : UIView

@property (nonatomic, weak) id<VZColorPanelViewDelegate> delegate;

- (void)updateColor:(UIColor *)color;

- (id)initWithFrame:(CGRect)frame defaultRatio:(NSInteger)defaultRatio;

@end
