//
//  NSObject+VZAllocationTracker.m
//  APInspector
//
//  Created by 净枫 on 16/8/15.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#if __has_feature(objc_arc)
#error This file must be compiled with MRR. Use -fno-objc-arc flag.
#endif


#import "NSObject+VZAllocationTracker.h"
#import "VZAllocationTrackerDefines.h"
#import "VZAllocationTrackerHelpers.h"

@implementation NSObject (VZAllocationTracker)

+ (id)vz_originalAlloc
{
    // Placeholder for original alloc
    return nil;
}

- (void)vz_originalDealloc
{
    // Placeholder for original dealloc
}

+ (id)vz_newAlloc
{
        
    id object = [self vz_originalAlloc];
    VZ::AllocationTracker::incrementAllocations(object);
    return object;
}

- (void)vz_newDealloc
{
    VZ::AllocationTracker::incrementDeallocations(self);
    [self vz_originalDealloc];
}
@end
