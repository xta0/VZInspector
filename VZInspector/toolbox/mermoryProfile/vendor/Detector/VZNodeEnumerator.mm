/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "VZNodeEnumerator.h"

#import "VZObjectiveCGraphElement.h"

@implementation VZNodeEnumerator
{
  NSSet *_retainedObjectsSnapshot;
  NSEnumerator *_enumerator;
}

- (instancetype)initWithObject:(VZObjectiveCGraphElement *)object
{
  if (self = [super init]) {
    _object = object;
  }

  return self;
}

- (VZNodeEnumerator *)nextObject
{
  if (!_object) {
    return nil;
  } else if (!_retainedObjectsSnapshot) {
    _retainedObjectsSnapshot = [_object allRetainedObjects];
    _enumerator = [_retainedObjectsSnapshot objectEnumerator];
  }

  VZObjectiveCGraphElement *next = [_enumerator nextObject];

  if (next) {
    return [[VZNodeEnumerator alloc] initWithObject:next];
  }

  return nil;
}

- (BOOL)isEqual:(id)object
{
  if ([object isKindOfClass:[VZNodeEnumerator class]]) {
    VZNodeEnumerator *enumerator = (VZNodeEnumerator *)object;
    return [self.object isEqual:enumerator.object];
  }

  return NO;
}

- (NSUInteger)hash
{
  return [self.object hash];
}

@end
