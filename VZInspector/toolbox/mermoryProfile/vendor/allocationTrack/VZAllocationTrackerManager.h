//
//  VZAllocationTrackerManager.h
//  APInspector
//
//  Created by 净枫 on 16/8/15.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    
BOOL VZIsFBATEnabledInThisBuild(void);
    
#ifdef __cplusplus
}
#endif

@class VZAllocationTrackerSummary;


@interface VZAllocationTrackerManager : NSObject

+ (nullable instancetype)sharedManager;

- (void)startTrackingAllocations;

- (void)stopTrackingAllocations;
- (BOOL)isAllocationTrackerEnabled;

- (void)incrementAllocations:(nullable __unsafe_unretained id)object;

- (void)incrementDeallocations:(nullable __unsafe_unretained id)object;

- (nullable NSArray<VZAllocationTrackerSummary *> *)currentAllocationSummary;
- (nullable NSArray *)instancesOfClasses:(nonnull NSArray *)classes;
- (nullable NSSet<Class> *)trackedClasses;


@end
