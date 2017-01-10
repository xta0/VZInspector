/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import "VZObjectGraphConfiguration.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 Standard filters mostly filters excluding some UIKit references we have caught during testing on some apps.
 */
NSArray<VZGraphEdgeFilterBlock> *_Nonnull VZGetStandardGraphEdgeFilters();

/**
 Helper functions for some typical patterns.
 */
VZGraphEdgeFilterBlock _Nonnull VZFilterBlockWithObjectIvarRelation(Class _Nonnull aCls,
                                                                    NSString *_Nonnull ivarName);
VZGraphEdgeFilterBlock _Nonnull VZFilterBlockWithObjectToManyIvarsRelation(Class _Nonnull aCls,
                                                                           NSSet<NSString *> *_Nonnull ivarNames);
VZGraphEdgeFilterBlock _Nonnull VZFilterBlockWithObjectIvarObjectRelation(Class _Nonnull fromClass,
                                                                          NSString *_Nonnull ivarName,
                                                                          Class _Nonnull toClass);

#ifdef __cplusplus
}
#endif
