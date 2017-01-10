//
//  VZAllocationTrackerHelpers.h
//  APInspector
//
//  Created by 净枫 on 2016/12/19.
//  Copyright © 2016年 Alipay. All rights reserved.
//


namespace VZ { namespace AllocationTracker {
    
    /**
     Helper function that NSObject swizzles will use to increment on alloc
     */
    void incrementAllocations(__unsafe_unretained id obj);
    
    /**
     Helper function that NSObject swizzles will use to decrement on dealloc
     */
    void incrementDeallocations(__unsafe_unretained id obj);
    
} }
