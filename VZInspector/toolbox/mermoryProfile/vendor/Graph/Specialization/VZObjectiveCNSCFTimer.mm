/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "VZObjectiveCNSCFTimer.h"

#import <objc/runtime.h>

#import "VZRetainCycleDetector.h"
#import "VZRetainCycleUtils.h"

@implementation VZObjectiveCNSCFTimer

#if _INTERNAL_RCD_ENABLED

typedef struct {
  long _unknown; // This is always 1
  id target;
  SEL selector;
  NSDictionary *userInfo;
} _VZNSCFTimerInfoStruct;

- (NSSet *)allRetainedObjects
{
  // Let's retain our timer
  __attribute__((objc_precise_lifetime)) NSTimer *timer = self.object;

  if (!timer) {
    return nil;
  }

  NSMutableSet *retained = [[super allRetainedObjects] mutableCopy];

  CFRunLoopTimerContext context;
  CFRunLoopTimerGetContext((CFRunLoopTimerRef)timer, &context);

  // If it has a retain function, let's assume it retains strongly
  NSString *namePathClassName = NSStringFromClass([self.object class]);

  if (context.info && context.retain) {
    _VZNSCFTimerInfoStruct infoStruct = *(_VZNSCFTimerInfoStruct *)(context.info);
    if (infoStruct.target) {
      [retained addObject:VZWrapObjectGraphElementWithContext(infoStruct.target, self.configuration, @[@"target"],namePathClassName)];
    }
    if (infoStruct.userInfo) {
      [retained addObject:VZWrapObjectGraphElementWithContext(infoStruct.userInfo, self.configuration, @[@"userInfo"],namePathClassName)];
    }
  }

  return retained;
}

#endif // _INTERNAL_RCD_ENABLED

@end
