/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <stack>
#import <unordered_map>
#import <unordered_set>

#import "VZNodeEnumerator.h"
#import "VZObjectiveCGraphElement.h"
#import "VZObjectiveCObject.h"
#import "VZRetainCycleDetector+Internal.h"
#import "VZRetainCycleUtils.h"
#import "VZStandardGraphEdgeFilters.h"

static const NSUInteger kVZRetainCycleDetectorDefaultStackDepth = 10;

@implementation VZRetainCycleDetector
{
  NSMutableArray *_candidates;
  VZObjectGraphConfiguration *_configuration;
}

- (instancetype)initWithConfiguration:(VZObjectGraphConfiguration *)configuration
{
  if (self = [super init]) {
    _configuration = configuration;
    _candidates = [NSMutableArray new];
  }
  
  return self;
}

- (instancetype)init
{
  return [self initWithConfiguration:
          [[VZObjectGraphConfiguration alloc] initWithFilterBlocks:VZGetStandardGraphEdgeFilters()
                                               shouldInspectTimers:YES]];
}

- (void)addCandidate:(id)candidate
{
  VZObjectiveCGraphElement *graphElement = VZWrapObjectGraphElement(candidate, _configuration);
  [_candidates addObject:graphElement];
}

- (NSSet<NSArray<VZObjectiveCGraphElement *> *> *)findRetainCycles
{
  return [self findRetainCyclesWithMaxCycleLength:kVZRetainCycleDetectorDefaultStackDepth];
}

- (NSSet<NSArray<VZObjectiveCGraphElement *> *> *)findRetainCyclesWithMaxCycleLength:(NSUInteger)length
{
  NSMutableSet<NSArray<VZObjectiveCGraphElement *> *> *allRetainCycles = [NSMutableSet new];
  for (VZObjectiveCGraphElement *graphElement in _candidates) {
    NSSet<NSArray<VZObjectiveCGraphElement *> *> *retainCycles = [self _findRetainCyclesInObject:graphElement
                                                                                      stackDepth:length];
    [allRetainCycles unionSet:retainCycles];
  }
  [_candidates removeAllObjects];

  return allRetainCycles;
}

- (NSSet<NSArray<VZObjectiveCGraphElement *> *> *)_findRetainCyclesInObject:(VZObjectiveCGraphElement *)graphElement
                                                                 stackDepth:(NSUInteger)stackDepth
{
  NSMutableSet<NSArray<VZObjectiveCGraphElement *> *> *retainCycles = [NSMutableSet new];
  VZNodeEnumerator *wrappedObject = [[VZNodeEnumerator alloc] initWithObject:graphElement];

  // We will be doing DFS over graph of objects

  // Stack will keep current path in the graph
  NSMutableArray<VZNodeEnumerator *> *stack = [NSMutableArray new];

  // To make the search non-linear we will also keep
  // a set of previously visited nodes.
  NSMutableSet<VZNodeEnumerator *> *objectsOnPath = [NSMutableSet new];

  // Let's start with the root
  [stack addObject:wrappedObject];

  while ([stack count] > 0) {
    // Algorithm creates many short-living objects. It can contribute to few
    // hundred megabytes memory jumps if not handled correctly, therefore
    // we're gonna drain the objects with our autoreleasepool.
    @autoreleasepool {
      // Take topmost node in stack and mark it as visited
      VZNodeEnumerator *top = [stack lastObject];
      [objectsOnPath addObject:top];

      // Take next adjecent node to that child. Wrapper object can
      // persist iteration state. If we see that node again, it will
      // give us new adjacent node unless it runs out of them
      VZNodeEnumerator *firstAdjacent = [top nextObject];
      if (firstAdjacent) {
        // Current node still has some adjacent not-visited nodes

        BOOL shouldPushToStack = NO;

        // Check if child was already seen in that path
        if ([objectsOnPath containsObject:firstAdjacent]) {
          // We have caught a retain cycle

          // Ignore the first element which is equal to firstAdjacent, use firstAdjacent
          // we're doing that because firstAdjacent has set all contexts, while its
          // first occurence could be a root without any context
          NSUInteger index = [stack indexOfObject:firstAdjacent];
          NSInteger length = [stack count] - index;

          if (index == NSNotFound) {
            // Object got deallocated between checking if it exists and grabbing its index
            shouldPushToStack = YES;
          } else {
            NSRange cycleRange = NSMakeRange(index, length);
            NSMutableArray<VZNodeEnumerator *> *cycle = [[stack subarrayWithRange:cycleRange] mutableCopy];
            [cycle replaceObjectAtIndex:0 withObject:firstAdjacent];

            // 1. Unwrap the cycle
            // 2. Shift to lowest address (if we omit that, and the cycle is created by same class,
            //    we might have duplicates)
            // 3. Shift by class (lexicographically)

            [retainCycles addObject:[self _shiftToUnifiedCycle:[self _unwrapCycle:cycle]]];
          }
        } else {
          // Node is clear to check, add it to stack and continue
          shouldPushToStack = YES;
        }

        if (shouldPushToStack) {
          if ([stack count] < stackDepth) {
            [stack addObject:firstAdjacent];
          }
        }
      } else {
        // Node has no more adjacent nodes, it itself is done, move on
        [stack removeLastObject];
        [objectsOnPath removeObject:top];
      }
    }
  }
  return retainCycles;
}

// Turn all enumerators into object graph elements
- (NSArray<VZObjectiveCGraphElement *> *)_unwrapCycle:(NSArray<VZNodeEnumerator *> *)cycle
{
  NSMutableArray *unwrappedArray = [NSMutableArray new];
  for (VZNodeEnumerator *wrapped in cycle) {
    [unwrappedArray addObject:wrapped.object];
  }

  return unwrappedArray;
}

// We do that so two cycles can be recognized as duplicates
- (NSArray<VZObjectiveCGraphElement *> *)_shiftToUnifiedCycle:(NSArray<VZObjectiveCGraphElement *> *)array
{
  return [self _shiftToLowestLexicographically:[self _shiftBufferToLowestAddress:array]];
}

- (NSArray<NSString *> *)_extractClassNamesFromGraphObjects:(NSArray<VZObjectiveCGraphElement *> *)array
{
  NSMutableArray *arrayOfClassNames = [NSMutableArray new];

  for (VZObjectiveCGraphElement *obj in array) {
    [arrayOfClassNames addObject:[obj classNameOrNull]];
  }

  return arrayOfClassNames;
}

/**
 The problem this circular shift solves is when we have few retain cycles for different runs that
 are technically the same cycle shifted. Object instances are different so if objects A and B
 create cycle, but on one run the address of A is lower than B, and on second B is lower than A,
 we will get a duplicate we have to get rid off.

 For that not to happen we use the circular shift that is smallest lexicographically when
 looking at class names.

 The version of this algorithm is pretty inefficient. It just compares given shifts and
 tries to find the smallest one. Doing something faster here is premature optimisation though
 since the retain cycles are usually arrays of length not bigger than 10 and there is not a lot
 of them (like 100 per run tops).

 If that ever occurs to be a problem for future reference use lexicographically minimal
 string rotation algorithm variation.
 */
- (NSArray<VZObjectiveCGraphElement *> *)_shiftToLowestLexicographically:(NSArray<VZObjectiveCGraphElement *> *)array
{
  NSArray<NSString *> *arrayOfClassNames = [self _extractClassNamesFromGraphObjects:array];

  NSArray<NSString *> *copiedArray = [arrayOfClassNames arrayByAddingObjectsFromArray:arrayOfClassNames];
  NSUInteger originalLength = [arrayOfClassNames count];

  NSArray *currentMinimalArray = arrayOfClassNames;
  NSUInteger minimumIndex = 0;

  for (NSUInteger i = 0; i < originalLength; ++i) {
    NSArray<NSString *> *nextSubarray = [copiedArray subarrayWithRange:NSMakeRange(i, originalLength)];
    if ([self _compareStringArray:currentMinimalArray
                        withArray:nextSubarray] == NSOrderedDescending) {
      currentMinimalArray = nextSubarray;
      minimumIndex = i;
    }
  }

  NSRange minimumArrayRange = NSMakeRange(minimumIndex,
                                          [array count] - minimumIndex);
  NSMutableArray<VZObjectiveCGraphElement *> *minimumArray = [[array subarrayWithRange:minimumArrayRange] mutableCopy];
  [minimumArray addObjectsFromArray:[array subarrayWithRange:NSMakeRange(0, minimumIndex)]];
  return minimumArray;
}

- (NSComparisonResult)_compareStringArray:(NSArray<NSString *> *)a1
                                withArray:(NSArray<NSString *> *)a2
{
  // a1 and a2 should be the same length
  for (NSUInteger i = 0; i < [a1 count]; ++i) {
    NSString *s1 = a1[i];
    NSString *s2 = a2[i];

    NSComparisonResult comparision = [s1 compare:s2];
    if (comparision != NSOrderedSame) {
      return comparision;
    }
  }

  return NSOrderedSame;
}

- (NSArray<VZObjectiveCGraphElement *> *)_shiftBufferToLowestAddress:(NSArray<VZObjectiveCGraphElement *> *)cycle
{
  NSUInteger idx = 0, lowestAddressIndex = 0;
  size_t lowestAddress = NSUIntegerMax;
  for (VZObjectiveCGraphElement *obj in cycle) {
    if ([obj objectAddress] < lowestAddress) {
      lowestAddress = [obj objectAddress];
      lowestAddressIndex = idx;
    }

    idx++;
  }

  if (lowestAddressIndex == 0) {
    return cycle;
  }

  NSRange cycleRange = NSMakeRange(lowestAddressIndex, [cycle count] - lowestAddressIndex);
  NSMutableArray<VZObjectiveCGraphElement *> *array = [[cycle subarrayWithRange:cycleRange] mutableCopy];
  [array addObjectsFromArray:[cycle subarrayWithRange:NSMakeRange(0, lowestAddressIndex)]];
  return array;
}

@end
