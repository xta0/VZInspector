/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "VZAllocationTrackerGeneration.h"

#import <objc/message.h>
#import <objc/runtime.h>

#import "VZAllocationTrackerNSZombieSupport.h"

namespace VZ { namespace AllocationTracker {
  void Generation::addObject(__unsafe_unretained id object) {
    Class aCls = [object class];
    objects[aCls].insert(object);
  }

  void Generation::removeObject(__unsafe_unretained id object) {
    Class aCls = [object class];
    objects[aCls].erase(object);
      const GenerationList &list = objects[aCls];
      if(list.size() == 0){
          objects.erase(aCls);
      }
  }
    
  BOOL Generation::findObject(__unsafe_unretained id object){
      Class aCls = [object class];
      const GenerationMap::const_iterator obj = objects.find(aCls);
      if(obj != objects.end()){
          const GenerationList &list = obj->second;
          for(const auto &searchObj :list){
              if(searchObj == object){
                  return YES;
              }
          }
      }
      return NO;
  }

  GenerationSummary Generation::getSummary() const {
    GenerationSummary summary;

    for (const auto &kv: objects) {
      Class aCls = kv.first;
      const GenerationList &list = kv.second;

      NSInteger count = list.size();

      summary[aCls] = count;
    }

    return summary;
  }
    
 

  std::vector<__weak id> Generation::instancesForClass(__unsafe_unretained Class aCls) const {
    std::vector<__weak id> returnValue;

    const GenerationMap::const_iterator obj = objects.find(aCls);
    if (obj != objects.end()) {
      const GenerationList &list = obj->second;
      for (const auto &object: list) {
        __weak id weakObject = nil;

        BOOL (*allowsWeakReference)(id, SEL) =
        (__typeof__(allowsWeakReference))class_getMethodImplementation(aCls, @selector(allowsWeakReference));

        if (allowsWeakReference && (IMP)allowsWeakReference != _objc_msgForward) {
          if (allowsWeakReference(object, @selector(allowsWeakReference))) {
            // This is still racey since allowsWeakReference could change it value by now.
            weakObject = object;
          }
        } else {
          weakObject = object;
        }

        /**
         Retain object and add it to returnValue.
         This operation can be unsafe since we are retaining object that could
         be deallocated on other thread.

         When NSZombie enabled, we can find if object has been deallocated by checking its class name.
         */
        if (!vz_isZombieObject(weakObject)) {
          returnValue.push_back(weakObject);
        }
      }
    }

    return returnValue;
  }

} }
