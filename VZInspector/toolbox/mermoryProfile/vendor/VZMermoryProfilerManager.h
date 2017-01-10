//
//  VZMermoryProfilerManager.h
//  APInspector
//
//  Created by 净枫 on 16/8/16.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VZAllocationTrackerSummary.h"
typedef NS_ENUM(NSUInteger,VZMermoryRetainCycleStatus ){
    VZMermoryRetainCycleStatusUnKnown = 0,
    VZMermoryRetainCycleStatusLeak ,
    VZMermoryRetainCycleStatusNotLeak
};

@interface VZMermoryProfilerManager : NSObject

+ (nullable instancetype)sharedManager;

- (void)startTracking;

- (void)endTracking;

- (nullable NSArray<VZAllocationTrackerSummary *> *)currentAllocationSummary;

- (nullable NSArray *)instancesOfClasses:(nonnull NSArray *)classes;

- (nullable NSSet<Class> *)trackedClasses;

- (nullable NSSet<Class> *)trackedClassesForRetainCycle:(BOOL)retainCycle;

- (NSSet<NSArray *> *)findRetainCyclesForClassName:(NSString *)className;

- (VZMermoryRetainCycleStatus)retainCycleStatusForClassName:(NSString *)className;

- (void)updateMermoryClassBlackKeys:(NSArray<NSString *> *) blackKeys;

- (void)updateMermoryClassWhiteKeys:(NSArray<NSString *> *) whiteKeys;;


@end
