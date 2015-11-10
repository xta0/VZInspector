//
//  O2OMethodTrace+Statistic.m
//  testinvocation
//
//  Created by lingwan on 10/16/15.
//  Copyright © 2015 lingwan. All rights reserved.
//

#import "O2OMethodTrace+Statistic.h"

@implementation O2OMethodTrace (Statistic)

static showTracedResult block;
+ (void)setShowResultBlock:(showTracedResult)b {
    block = b;
}

+ (void)processNewSEL:(SEL)selector {
    NSString *selName = NSStringFromSelector(selector);
    
    [[O2OMethodTrace stackArray] addObject:selName];
    
    NSMutableDictionary *sharedStorage = [O2OMethodTrace statisticDict];
    if (![sharedStorage valueForKey:selName]) {
        [sharedStorage setValue:@(1) forKey:selName];
    } else {
        NSNumber *count = [sharedStorage valueForKey:selName];
        [sharedStorage setValue:@(count.integerValue + 1) forKey:selName];
    }
    
    if (!block) {
        return;
    }
    
    //Show result
    __block NSString *stackStr = @"";
    [[O2OMethodTrace stackArray] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        stackStr = [stackStr stringByAppendingFormat:@"%@\n", obj];
    }];
    
    NSMutableDictionary *statisticDict = [O2OMethodTrace statisticDict];
    NSArray *sortedKeys = [statisticDict keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber  * _Nonnull obj1, NSNumber  *  _Nonnull obj2) {
        if (obj1.integerValue > obj2.integerValue) {
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
    }];
    
    __block NSString *statisticStr = @"";
    [sortedKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        statisticStr = [statisticStr stringByAppendingFormat:@"%@  %@\n", [statisticDict valueForKey:obj], obj];
    }];
    
    block(stackStr, statisticStr);
}

+ (NSMutableArray *)stackArray {
    static NSMutableArray *stackArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stackArray = [NSMutableArray array];
    });
    
    return stackArray;
}

+ (NSMutableDictionary *)statisticDict {
    static NSMutableDictionary *statisticDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        statisticDict = [NSMutableDictionary dictionary];
    });
    
    return statisticDict;
}

@end
