/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "VZObjectiveCBlock.h"

#import <objc/runtime.h>

#import "VZBlockStrongLayout.h"
#import "VZObjectiveCObject.h"
#import "VZRetainCycleUtils.h"

@implementation VZObjectiveCBlock

- (NSSet *)allRetainedObjects
{
  NSArray *unfiltered = [self _unfilteredRetainedObjects];
  return [self filterObjects:unfiltered];
}

- (NSArray *)_unfilteredRetainedObjects
{
  NSMutableArray *results = [[[super allRetainedObjects] allObjects] mutableCopy];

  // Grab a strong reference to the object, otherwise it can crash while doing
  // nasty stuff on deallocation
  __attribute__((objc_precise_lifetime)) id anObject = self.object;

  void *blockObjectReference = (__bridge void *)anObject;
  NSArray *allRetainedReferences = VZGetBlockStrongReferences(blockObjectReference);

    NSString *className = NSStringFromClass([self.object class]);
  for (id object in allRetainedReferences) {
    [results addObject:VZWrapObjectGraphElementWithContext(object, self.configuration, @[@"block"] , className)];
  }

  return results;
}

@end
