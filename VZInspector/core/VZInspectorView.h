//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZInspectorView : UIView

@property(nonatomic,weak) UIViewController* parentViewController;

- (id)initWithFrame:(CGRect)frame parentViewController:(UIViewController* )controller;
- (void)update;
- (void)pop;
- (BOOL)canTouchPassThrough:(CGPoint)pt;

@end
