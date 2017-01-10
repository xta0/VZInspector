//
//  VZAllocationTrackerManager.m
//  APInspector
//
//  Created by 净枫 on 16/8/15.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZAllocationTrackerManager.h"
#import "VZAllocationTrackerDefines.h"
#import "VZAllocationTrackerImpl.h"
#import "VZAllocationTrackerSummary.h"
#import "VZAllocationTrackerHelpers.h"
#import <objc/runtime.h>

BOOL VZIsFBATEnabledInThisBuild(void)
{
    return YES;
}

@implementation VZAllocationTrackerManager{
    dispatch_queue_t _queue;
    NSUInteger _generationsClients;

}

- (instancetype)init
{
    if (self = [super init]) {
        _queue = dispatch_queue_create("vzallocationTrackerManager", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static VZAllocationTrackerManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [VZAllocationTrackerManager new];
    });
    return sharedManager;
}


- (void)startTrackingAllocations{
    dispatch_async(_queue, ^{
        VZ::AllocationTracker::init();
        VZ::AllocationTracker::enableGenerations();
        VZ::AllocationTracker::beginTracking();

    });
}

- (void)stopTrackingAllocations{
    dispatch_async(_queue, ^{
        VZ::AllocationTracker::disableGenerations();
        VZ::AllocationTracker::endTracking();        
    });
}
- (BOOL)isAllocationTrackerEnabled{
    
    return VZ::AllocationTracker::isTracking();
}

- (void)incrementAllocations:(nullable __unsafe_unretained id)object{
    VZ::AllocationTracker::incrementAllocations(object);
}

- (void)incrementDeallocations:(nullable __unsafe_unretained id)object{
    VZ::AllocationTracker::incrementDeallocations(object);
}


- (nullable NSArray<VZAllocationTrackerSummary *> *)currentAllocationSummary{
    VZ::AllocationTracker::AllocationSummary summary = VZ::AllocationTracker::allocationTrackerSummary();
    NSMutableArray *array = [NSMutableArray new];
    
    for(const auto &item : summary){
        VZ::AllocationTracker::SingleClassSummary singleSummary = item.second;
        Class aCls = item.first;
        NSString * className = NSStringFromClass(aCls);
        VZAllocationTrackerSummary *summaryObject = [[VZAllocationTrackerSummary alloc]initWithAllocations:singleSummary.allocations deallocations:singleSummary.deallocations aliveObjects:(singleSummary.allocations - singleSummary.deallocations) className:className instanceSize:singleSummary.instanceSize];
        [array addObject:summaryObject];
    }
    return array;
}
- (nullable NSArray *)instancesOfClasses:(nonnull NSArray *)classes{
    return VZ::AllocationTracker::instancesOfClasses(classes);
}
- (nullable NSSet<Class> *)trackedClasses{
    std::vector<__unsafe_unretained Class> classes = VZ::AllocationTracker::trackedClasses();
    return [NSSet setWithObjects:classes.data() count:classes.size()];
}

@end
