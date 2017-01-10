/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "VZStandardGraphEdgeFilters.h"

#import <objc/runtime.h>

#import <UIKit/UIKit.h>

#import "VZObjectiveCGraphElement.h"
#import "VZRetainCycleDetector.h"

VZGraphEdgeFilterBlock VZFilterBlockWithObjectIvarRelation(Class aCls, NSString *ivarName) {
  return VZFilterBlockWithObjectToManyIvarsRelation(aCls, [NSSet setWithObject:ivarName]);
}

VZGraphEdgeFilterBlock VZFilterBlockWithObjectToManyIvarsRelation(Class aCls,
                                                                  NSSet<NSString *> *ivarNames) {
  return ^(VZObjectiveCGraphElement *fromObject,
           VZObjectiveCGraphElement *toObject){
    if (aCls &&
        [[fromObject objectClass] isSubclassOfClass:aCls]) {
      // If graph element holds metadata about an ivar, it will be held in the name path, as early as possible
      NSString *ivarName = [[toObject namePath] objectAtIndex:0];
      if ([ivarNames containsObject:ivarName]) {
        return VZGraphEdgeInvalid;
      }
    }
    return VZGraphEdgeValid;
  };
}

VZGraphEdgeFilterBlock VZFilterBlockWithObjectIvarObjectRelation(Class fromClass, NSString *ivarName, Class toClass) {
  return ^(VZObjectiveCGraphElement *fromObject,
           VZObjectiveCGraphElement *toObject) {
    if (toClass &&
        [[toObject objectClass] isSubclassOfClass:toClass]) {
      return VZFilterBlockWithObjectIvarRelation(fromClass, ivarName)(fromObject, toObject);
    }
    return VZGraphEdgeValid;
  };
}

NSArray<VZGraphEdgeFilterBlock> *VZGetStandardGraphEdgeFilters() {
#if _INTERNAL_RCD_ENABLED
  static Class heldActionClass;
  static Class transitionContextClass;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    heldActionClass = NSClassFromString(@"UIHeldAction");
    transitionContextClass = NSClassFromString(@"_UIViewControllerOneToOneTransitionContext");
  });

  return @[VZFilterBlockWithObjectIvarRelation([UIView class], @"_subviewCache"),
           VZFilterBlockWithObjectIvarRelation(heldActionClass, @"m_target"),
           VZFilterBlockWithObjectToManyIvarsRelation([UITouch class],
                                                      [NSSet setWithArray:@[@"_view",
                                                                            @"_gestureRecognizers",
                                                                            @"_window",
                                                                            @"_warpedIntoView"]]),
           VZFilterBlockWithObjectToManyIvarsRelation(transitionContextClass,
                                                      [NSSet setWithArray:@[@"_toViewController",
                                                                            @"_fromViewController"]])];
#else
  return nil;
#endif // _INTERNAL_RCD_ENABLED
}
