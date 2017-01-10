//
//  VZInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VZInspectController.h"
#import "VZInspectorToolItem.h"

@interface VZInspector : NSObject

/*
 *在状态栏显示入口
 */
+ (void)showOnStatusBar;
+ (BOOL)isShow;
/*
 *打开inspector
 */
+ (void)show;
/*
 *关闭inspector
 */
+ (void)hide;
/*
 *设置业务类代码前缀
 */
+ (void)setClassPrefixName:(NSString* )name;
/*
 *是否要记录crash日志
 */
+ (void)setShouldHandleCrash:(BOOL)b;
/**
 *是否要hook网络请求
 */
+ (void)setShouldHookNetworkRequest:(BOOL)b;
/**
 * 设置log数量限制
 */
+ (void)setLogNumbers:(NSUInteger)num;
/*
 *注入要观察的全局信息
 */
+ (void)addObserveCallback:(NSString* (^)(void)) callback;
/**
 *  注入自定义插件
 */
+ (void)addToolItem:(VZInspectorToolItem *)toolItem;
/*
 *  返回所有注册的自定义插件
 */
+ (NSArray *)additionTools;

@end


@interface VZInspector(env)
/**
 *  增加 Dashboard 头部开关
 */
+ (void)addDashboardSwitch:(NSString* )type Highlight:(BOOL)highligh Callback:(void(^)(void))callback;



@end
