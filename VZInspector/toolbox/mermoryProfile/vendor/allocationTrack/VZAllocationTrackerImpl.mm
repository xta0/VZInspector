/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "VZAllocationTrackerImpl.h"

#import <objc/runtime.h>
#import <unordered_map>
#import <unordered_set>
#import <vector>
#import <mutex>


#import "VZAllocationTrackerDefines.h"
#import "NSObject+VZAllocationTracker.h"
#import "VZAllocationTrackerHelpers.h"

typedef NS_ENUM(NSUInteger, VZMethodType) {
  VZInstanceMethod,
  VZClassMethod,
};

namespace {
  // Private
  using TrackerMap =
  std::unordered_map<
  __unsafe_unretained Class,
  NSUInteger,
  VZ::AllocationTracker::ClassHashFunctor,
  VZ::AllocationTracker::ClassEqualFunctor>;

  // Pointers to avoid static deallocation fiasco
  static TrackerMap *_allocations ;
  static TrackerMap *_deallocations ;
  static bool _trackingInProgress;
  static std::mutex *_lock ;

    
    
  // Private interface
  static bool _didCopyOriginalMethods;

    
   static VZ::AllocationTracker::Generation *_generation = nil;
    

  void replaceSelectorWithSelector(Class aCls,
                                   SEL selector,
                                   SEL replacementSelector,
                                   VZMethodType methodType) {

    Method replacementSelectorMethod = (methodType == VZClassMethod
                                        ? class_getClassMethod(aCls, replacementSelector)
                                        : class_getInstanceMethod(aCls, replacementSelector));

    Class classEntityToEdit = aCls;
    if (methodType == VZClassMethod) {
      // Get meta-class
      classEntityToEdit = object_getClass(aCls);
    }
    class_replaceMethod(classEntityToEdit,
                        selector,
                        method_getImplementation(replacementSelectorMethod),
                        method_getTypeEncoding(replacementSelectorMethod));
  }

  void prepareOriginalMethods(void) {
    if (_didCopyOriginalMethods) {
      return;
    }

    // prepareOriginalMethods called from turnOn/Off which is synced by
    // _lock, this is thread-safe
    _didCopyOriginalMethods = true;

    replaceSelectorWithSelector([NSObject class],
                                @selector(vz_originalAlloc),
                                @selector(alloc),
                                VZClassMethod);

    replaceSelectorWithSelector([NSObject class],
                                @selector(vz_originalDealloc),
                                sel_registerName("dealloc"),
                                VZInstanceMethod);
  }

  void turnOnTracking(void) {
    prepareOriginalMethods();

    replaceSelectorWithSelector([NSObject class],
                                @selector(alloc),
                                @selector(vz_newAlloc),
                                VZClassMethod);

    replaceSelectorWithSelector([NSObject class],
                                sel_registerName("dealloc"),
                                @selector(vz_newDealloc),
                                VZInstanceMethod);
  }

  void turnOffTracking(void) {
    prepareOriginalMethods();

    replaceSelectorWithSelector([NSObject class],
                                @selector(alloc),
                                @selector(vz_originalAlloc),
                                VZClassMethod);

    replaceSelectorWithSelector([NSObject class],
                                sel_registerName("dealloc"),
                                @selector(vz_originalDealloc),
                                VZInstanceMethod);
  }
}

namespace VZ { namespace AllocationTracker {

    
    
  void beginTracking() {
    std::lock_guard<std::mutex> l(*_lock);

    if (_trackingInProgress) {
      return;
    }

    _trackingInProgress = true;

    turnOnTracking();
  }

  void endTracking() {
    std::lock_guard<std::mutex> l(*_lock);

    if (!_trackingInProgress) {
      return;
    }

    _trackingInProgress = false;

    _allocations->clear();
    _deallocations->clear();

    turnOffTracking();
  }

  bool isTracking() {
    std::lock_guard<std::mutex> l(*_lock);
    bool isTracking = _trackingInProgress;
    return isTracking;
  }

  static bool _shouldTrackClass(Class aCls) {
    if (aCls == Nil) {
      return false;
    }

    // We want to omit some classes for performance reasons
    static Class blacklistedTaggedPointerContainerClass;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      blacklistedTaggedPointerContainerClass = NSClassFromString(@"NSTaggedPointerStringCStringContainer");
    });

    if (aCls == blacklistedTaggedPointerContainerClass) {
      return false;
    }
      

    return true;
  }

    bool vz_canretain(__unsafe_unretained id obj){
        
        if(!obj){
            return false;
        }
        const char* clzname = object_getClassName(obj);
        if (!strcmp(clzname, "NSAutoreleasePool")) {
            return false;
        }
        
        if(![obj isKindOfClass:[NSObject class]]){
            return false;
        }
        
        return true;
   }
    
  void incrementAllocations(__unsafe_unretained id obj) {
    Class aCls = [obj class];

    if (!vz_canretain(obj) ||!_shouldTrackClass(aCls) || _generation == nil) {
      return;
    }

    std::lock_guard<std::mutex> l(*_lock);

//      if(_generation->findObject(obj)){
//          return;
//      }
      
    if (_trackingInProgress) {
      (*_allocations)[aCls]++;
    }

    if (_generation) {
      _generation->addObject(obj);
    }
  }

  void incrementDeallocations(__unsafe_unretained id obj) {
    
      if(!vz_canretain(obj) || _generation == nil ){
          return;
      }
      
    Class aCls = [obj class];

    if (!_shouldTrackClass(aCls)) {
       return;
    }

    std::lock_guard<std::mutex> l(*_lock);
      
    if (_trackingInProgress) {
      (*_deallocations)[aCls]++;
    }

    if (_generation) {
      _generation->removeObject(obj);
    }
  }

  AllocationSummary allocationTrackerSummary() {
    TrackerMap allocationsUntilNow;
    TrackerMap deallocationsUntilNow;

    {
      std::lock_guard<std::mutex> l(*_lock);

      allocationsUntilNow = TrackerMap(*_allocations);
      deallocationsUntilNow = TrackerMap(*_deallocations);
    }

    std::unordered_set<
    __unsafe_unretained Class,
    VZ::AllocationTracker::ClassHashFunctor,
    VZ::AllocationTracker::ClassEqualFunctor> keys;

    for (const auto &kv: allocationsUntilNow) {
      keys.insert(kv.first);
    }

    for (const auto &kv: deallocationsUntilNow) {
      keys.insert(kv.first);
    }

    AllocationSummary summary;

    for (Class aCls: keys) {
      // Non-zero instances are the only interesting ones
      if (allocationsUntilNow[aCls] - deallocationsUntilNow[aCls] <= 0) {
        continue;
      }

      SingleClassSummary singleSummary = {
        .allocations = allocationsUntilNow[aCls],
        .deallocations = deallocationsUntilNow[aCls],
        .instanceSize = class_getInstanceSize(aCls),
      };

      summary[aCls] = singleSummary;
    }

    return summary;
  }

    void init(){
        _allocations = new TrackerMap();
        _deallocations = new TrackerMap();
        _trackingInProgress = false;
        _lock = (new std::mutex);
        _didCopyOriginalMethods = false;
    }

    
  void enableGenerations() {
    std::lock_guard<std::mutex> l(*_lock);
//      _trackingInProgress = YES;
    if (_generation) {
      return;
    }
    _generation = new Generation();
  }
  
  void disableGenerations(void) {
    std::lock_guard<std::mutex> l(*_lock);
      _trackingInProgress = NO;
    delete _generation;
    _generation = nil;
  }

    
   
    

  static bool _shouldOmitClass(Class aCls) {
    // Trying to retain NSAutoreleasePool/NSCFTimer is going to end up with crash.
    NSString *className = NSStringFromClass(aCls);
    if ([className isEqualToString:@"NSAutoreleasePool"] ||
        [className isEqualToString:@"NSCFTimer"]) {
      return true;
    }

    return false;
  }

  std::vector<__weak id> instancesOfClassForGeneration(__unsafe_unretained Class aCls) {
    if (_shouldOmitClass(aCls)) {
      return std::vector<__weak id> {};
    }

    std::lock_guard<std::mutex> l(*_lock);
    if (_generation) {
      return _generation->instancesForClass(aCls);
    }
    return std::vector<__weak id> {};
  }

  NSArray *instancesOfClasses(NSArray *classes) {
    if (!_generation) {
      return nil;
    }

    NSMutableArray *instances = [NSMutableArray new];

    for (Class aCls in classes) {
      if (_shouldOmitClass(aCls)) {
        continue;
      }

      std::vector<__weak id> instancesFromGeneration;

      {
        std::lock_guard<std::mutex> l(*_lock);
        instancesFromGeneration = _generation->instancesForClass(aCls);
      }

      for (const auto &obj: instancesFromGeneration) {
        if (obj) {
          [instances addObject:obj];
        }
      }
    }

    return instances;
  }

  std::vector<__unsafe_unretained Class> trackedClasses() {
    std::lock_guard<std::mutex> l(*_lock);
    std::vector<__unsafe_unretained Class> trackedClasses;

    // Some first approximation for number of classes
    trackedClasses.reserve(2048);

    if (!_trackingInProgress) {
      return trackedClasses;
    }

    for (const auto &mapValue: *_allocations) {
        Class cls = mapValue.first;
        if(cls){
            int deallocCount = (*_deallocations)[cls];
            int allocCount = mapValue.second;
            if(allocCount - deallocCount <= 0){
                continue;
            }
            trackedClasses.push_back(mapValue.first);
        }
    }

    return trackedClasses;
  }
    
} }

