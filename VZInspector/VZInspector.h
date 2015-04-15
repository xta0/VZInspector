//
//  VZInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

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

/*
 *注入要观察的全局信息
 */
+ (void)setObserveCallback:(NSString* (^)(void)) callback;

@end

@interface VZInspector(log)

/*
 *request log的结构:{@"identifier":@"",@"request":""}
 */
+ (void)setRequestLogNotificationIdentifier:(NSString* )identifier urlKey:(NSString* )url;
/*
 *response log的结构:{@"identifier":@"",@"response":"",@"error"}
 */
+ (void)setResponseLogNotificationIdentifier:(NSString* )identifier responseKey:(NSString* )response errorKey:(NSString* )error;

@end

@interface VZInspector(env)

/*
 *默认配置index
 */
+ (void)setDefaultAPIEnvIndex:(NSInteger)index;
/*
 *配置开发API环境
 */
+ (void)setDevAPIEnvCallback:(void(^)(void))callback;
/*
 *配置预发布API环境
 */
+ (void)setTestAPIEnvCallback:(void(^)(void))callback;
/*
 *配置线上环境API环境
 */
+ (void)setProductionAPIEnvCallback:(void(^)(void))callback;

@end
