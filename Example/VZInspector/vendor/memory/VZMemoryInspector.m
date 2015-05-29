//
//  VZMemoryInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZMemoryInspector.h"
#include <UIKit/UIKit.h>
#include <mach/mach.h>
#include <malloc/malloc.h>
#import "NSObject+VZInspector.h"

@interface VZMemoryInspector()
{
    dispatch_queue_t _lock;
}

@end

@implementation VZMemoryInspector


+ (instancetype)sharedInstance
{
    static VZMemoryInspector* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [VZMemoryInspector new];
    });
    return instance;
}

static vm_size_t            sPageSize = 0;
static vm_statistics_data_t sVMStats;


- (id)init
{
    self = [super init];
    
    if (self)
    {
        _lock = dispatch_queue_create( "com.ETMemoryMonitor.taskQueue", nil );
        
    }
    
    return self;
}
- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_lock);
#endif
}


//for internal use
+ (BOOL)updateHostStatistics {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &sPageSize);
    return (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&sVMStats, &host_size)
            == KERN_SUCCESS);
}
/*
 * The number of bytes in memory that used
 **/

+ (unsigned long long)bytesOfUsedMemory
{
    /*
     * stackoverflow.com/questions/7989864/watching-memory-usage-in-ios
     */
    //    struct task_basic_info info;
    //    mach_msg_type_number_t size = sizeof(info);
    //    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    //    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
    
    struct mstats stat = mstats();
    
    return  stat.bytes_used;
    
}

/**
 * The number of bytes in memory that are free.
 */
+ (unsigned long long)bytesOfFreeMemory
{
    return NSRealMemoryAvailable();
}
/**
 * The total number of bytes of memory.
 */
+ (unsigned long long)bytesOfTotalMemory
{
    [self updateHostStatistics];
    
    unsigned long long free_count   = (unsigned long long)sVMStats.free_count;
    unsigned long long active_count = (unsigned long long)sVMStats.active_count;
    unsigned long long inactive_count = (unsigned long long)sVMStats.inactive_count;
    unsigned long long wire_count =  (unsigned long long)sVMStats.wire_count;
    unsigned long long pageSize = (unsigned long long)sPageSize;
    
    unsigned long long mem_free = (free_count + active_count + inactive_count + wire_count) * pageSize;
    
    
    return mem_free;
}
+ (void)performLowMemoryWarning
{
#ifdef DEBUG
    SEL memoryWarningSel =  NSSelectorFromString(@"_performMemoryWarning");
    if ([[UIApplication sharedApplication] respondsToSelector:memoryWarningSel]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [[UIApplication sharedApplication] performSelector:memoryWarningSel];
#pragma clang diagnostic pop
        
        NSLog(@"[%@]-->memory warning",self.class);
        
    } else {
        // UIApplication no loger responds to _performMemoryWarning
        exit(1);
    }
#endif
}

/**
 * The number of bytes free on disk.
 */
+ (unsigned long long)bytesOfFreeDiskSpace
{
    return 0;
}
/**
 * The total number of bytes of disk space.
 */
+ (unsigned long long)bytesOfTotalDiskSpace
{
    return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - for debugger use

- (void)vz_heartBeat
{
    if (self.samplePoints == nil)
        self.samplePoints = [NSMutableArray new];
    
    [self.samplePoints addObject:[NSNumber numberWithUnsignedLongLong:[[self class] bytesOfUsedMemory]]];
    
    //keep last 50 points
    if ( [self.samplePoints count] > 50 )
    {
        NSRange range;
        range.location = 0;
        range.length = [self.samplePoints count] - 50;
        [self.samplePoints removeObjectsInRange:range];
    }
}


@end
