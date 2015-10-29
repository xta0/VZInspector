//
//  O2OMethodTraceHeader.h
//  testinvocation
//
//  Created by lingwan on 10/16/15.
//  Copyright © 2015 lingwan. All rights reserved.
//

#ifndef O2OMethodTraceHeader_h
#define O2OMethodTraceHeader_h

#import "O2OMethodTrace.h"
#import "O2OMethodTrace+Statistic.h"
#import "O2OMethodTraceView.h"

#endif /* O2OMethodTraceHeader_h */

//跟踪某个类
//+ (void)traceClass:(Class)className;

//设置一个展示trace结果的block，block里回传两个string，第一个是调用路径，第二个是调用次数统计
//+ (void)setShowResultBlock:(showTracedResult)block;