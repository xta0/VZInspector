//
//  NSObject+VZAllocationTracker.h
//  APInspector
//
//  Created by 净枫 on 16/8/15.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (VZAllocationTracker)

+ (nonnull id)vz_originalAlloc;
- (void)vz_originalDealloc;

+ (nonnull id)vz_newAlloc;
- (void)vz_newDealloc;

@end
