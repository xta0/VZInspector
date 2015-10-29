//
//  O2OMethodTrace+Statistic.h
//  testinvocation
//
//  Created by lingwan on 10/16/15.
//  Copyright © 2015 lingwan. All rights reserved.
//

#import "O2OMethodTrace.h"

@interface O2OMethodTrace (Statistic)

+ (void)setShowResultBlock:(showTracedResult)block;

+ (void)processNewSEL:(SEL)selector;

@end
