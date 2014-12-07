//
//  VZInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZInspector : NSObject

+ (void)showOnStatusBar;
+ (BOOL)isShow;
+ (void)show;
+ (void)hide;

+ (void)setClassPrefixName:(NSString* )name;
+ (void)setShouldHandleCrash:(BOOL)b;
+ (void)setObserveCallback:(NSString* (^)(void)) callback;


@end
