/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "VZObjectiveCGraphElement+Internal.h"

#import <objc/message.h>
#import <objc/runtime.h>

#import "VZAssociationManager.h"
#import "VZClassStrongLayout.h"
#import "VZObjectGraphConfiguration.h"
#import "VZRetainCycleUtils.h"
#import "VZRetainCycleDetector.h"

@implementation VZObjectiveCGraphElement

- (instancetype)initWithObject:(id)object
{
  return [self initWithObject:object
                configuration:[VZObjectGraphConfiguration new]];
}

- (instancetype)initWithObject:(id)object
                 configuration:(nonnull VZObjectGraphConfiguration *)configuration
{
  return [self initWithObject:object
                configuration:configuration
                     namePath:nil
             namePathClassName:nil];
}

- (instancetype)initWithObject:(id)object
                 configuration:(nonnull VZObjectGraphConfiguration *)configuration
                      namePath:(NSArray<NSString *> *)namePath
             namePathClassName:(NSString *)namePathClassName

{
  if (self = [super init]) {
#if _INTERNAL_RCD_ENABLED
    // We are trying to mimic how ObjectiveC does storeWeak to not fall into
    // _objc_fatal path
    // https://github.com/bavarious/objc4/blob/3f282b8dbc0d1e501f97e4ed547a4a99cb3ac10b/runtime/objc-weak.mm#L369

    Class aCls = object_getClass(object);
    BOOL (*allowsWeakReference)(id, SEL) =
    (__typeof__(allowsWeakReference))class_getMethodImplementation(aCls, @selector(allowsWeakReference));

    if (allowsWeakReference && (IMP)allowsWeakReference != _objc_msgForward) {
      if (allowsWeakReference(object, @selector(allowsWeakReference))) {
        // This is still racey since allowsWeakReference could change it value by now.
        _object = object;
      }
    } else {
      _object = object;
    }
#endif
    _namePath = namePath;
    _namePathClassName = namePathClassName;
    _configuration = configuration;
  }

  return self;
}

- (NSSet *)allRetainedObjects
{
  NSArray *retainedObjectsNotWrapped = [VZAssociationManager associationsForObject:_object];
  NSMutableSet *retainedObjects = [NSMutableSet new];

  NSString *namePathClassName = NSStringFromClass([self.object class]);
  for (id obj in retainedObjectsNotWrapped) {
    [retainedObjects addObject:VZWrapObjectGraphElementWithContext(obj,
                                                                   _configuration,
                                                                   @[@"__associated_object"],
                                                                   namePathClassName)];
  }

  return retainedObjects;
}

- (NSSet *)filterObjects:(NSArray *)objects
{
  NSMutableSet *filtered = [NSMutableSet new];

  for (VZObjectiveCGraphElement *reference in objects) {
    if (![self _shouldBreakGraphEdgeFromObject:self
                                      toObject:reference]) {
      [filtered addObject:reference];
    }
  }

  return filtered;
}

- (BOOL)_shouldBreakGraphEdgeFromObject:(VZObjectiveCGraphElement *)fromObject
                               toObject:(VZObjectiveCGraphElement *)toObject
{
  for (VZGraphEdgeFilterBlock filterBlock in _configuration.filterBlocks) {
    if (filterBlock(fromObject, toObject) == VZGraphEdgeInvalid) {
      return YES;
    }
  }

  return NO;
}

- (BOOL)isEqual:(id)object
{
  if ([object isKindOfClass:[VZObjectiveCGraphElement class]]) {
    VZObjectiveCGraphElement *objcObject = object;
    // Use pointer equality
    return objcObject.object == _object;
  }
  return NO;
}

- (NSUInteger)hash
{
  return (size_t)_object;
}

- (NSString *)description
{
  if (_namePath) {
    NSString *namePathStringified = [_namePath componentsJoinedByString:@" -> "];
    if(_namePathClassName){
        namePathStringified = [NSString stringWithFormat:@"%@(%@)" , _namePathClassName , namePathStringified];
    }
    return [NSString stringWithFormat:@"%@ -> %@ ", namePathStringified, object_getClass(_object)];
  }
  return [NSString stringWithFormat:@"-> %@ ", object_getClass(_object)];
}

- (NSString *)namePathDescrible{
    if(_namePath){
        return  [_namePath componentsJoinedByString:@" -> "];
    }
    return nil;
}

- (size_t)objectAddress
{
  return (size_t)_object;
}

- (NSString *)classNameOrNull
{
  NSString *className = NSStringFromClass(object_getClass(_object));
  if (!className) {
    className = @"Null";
  }

  return className;
}

- (Class)objectClass
{
  return object_getClass(_object);
}

@end
