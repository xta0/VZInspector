//
//  VZMemoryInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZMemoryInspector : NSObject

+ (instancetype)sharedInstance;

#pragma mark- Memory monitor

/*
 * The number of bytes in memory that used
 **/
+ (unsigned long long)bytesOfUsedMemory;

/**
 * The number of bytes in memory that are free.
 */
+ (unsigned long long)bytesOfFreeMemory;

/**
 * The total number of bytes of memory.
 */
+ (unsigned long long)bytesOfTotalMemory;
/**
 * Simulate low memory warning
 * notice : _performMemoryWarning is private api
 */
+ (void)performLowMemoryWarning;
/**
 * The number of bytes free on disk.
 */
+ (unsigned long long)bytesOfFreeDiskSpace;
/**
 * The total number of bytes of disk space.
 */
+ (unsigned long long)bytesOfTotalDiskSpace;

@end
