//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (VZInspector)

+ (BOOL)isSwizzled;
+ (void)blockEvent:(BOOL) b;
+ (void)swizzle:(BOOL)b;

@end
