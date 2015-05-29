//
//  UIWindow+VZInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (VZInspector)

+ (BOOL)isSwizzled;
+ (void)blockEvent:(BOOL) b;
+ (void)swizzle:(BOOL)b;

@end
