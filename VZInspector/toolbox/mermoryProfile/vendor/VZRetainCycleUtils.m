/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "VZRetainCycleUtils.h"

#import <objc/runtime.h>

#import "VZBlockStrongLayout.h"
#import "VZClassStrongLayout.h"
#import "VZObjectiveCBlock.h"
#import "VZObjectiveCGraphElement.h"
#import "VZObjectiveCNSCFTimer.h"
#import "VZObjectiveCObject.h"
#import "VZObjectGraphConfiguration.h"

VZObjectiveCGraphElement *VZWrapObjectGraphElementWithContext(id object,
                                                              VZObjectGraphConfiguration *configuration,
                                                              NSArray<NSString *> *namePath,
                                                              NSString *namePathClassName) {
    if (VZObjectIsBlock((__bridge void *)object)) {
        return [[VZObjectiveCBlock alloc] initWithObject:object
                                           configuration:configuration
                                                namePath:namePath
                                       namePathClassName:namePathClassName];
    } else {
        if ([object_getClass(object) isSubclassOfClass:[NSTimer class]] &&
            configuration.shouldInspectTimers) {
            return [[VZObjectiveCNSCFTimer alloc] initWithObject:object
                                                   configuration:configuration
                                                        namePath:namePath
                                               namePathClassName:namePathClassName];
        } else {
            return [[VZObjectiveCObject alloc] initWithObject:object
                                                configuration:configuration
                                                     namePath:namePath
                                            namePathClassName:namePathClassName];
        }
    }
}

VZObjectiveCGraphElement *VZWrapObjectGraphElement(id object,
                                                   VZObjectGraphConfiguration *configuration) {
    return VZWrapObjectGraphElementWithContext(object, configuration, nil ,nil);
}
