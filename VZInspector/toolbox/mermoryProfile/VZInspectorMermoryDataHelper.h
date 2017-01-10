//
//  VZInspectorMermoryDataHelper.h
//  APInspector
//
//  Created by 净枫 on 2016/12/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VZInspectorMermoryItem.h"

@interface VZInspectorMermoryDataHelper : NSObject

+ (instancetype)sharedInstance;

- (BOOL)canMermoryTrack;

- (void)updateMermoryTrackState:(BOOL)state;

- (void)startTrackingIfNeed;

- (void)endTrackingIfNeed;

- (NSMutableArray *)mermoryDatas;

- (NSMutableArray *)filterMermoryDatas:(NSString *)filter;

- (NSMutableArray *)mermoryDatasForRetainCycle:(BOOL)isRetainCycle;

- (NSMutableArray *)instancesForClassName:(VZInspectorMermoryItem *)item;

- (NSArray *)findRetainCyclesForInstances:(NSString *)className;

- (void)setClassLoadingStatus:(BOOL)isLoading className:(NSString *)className;

@end
