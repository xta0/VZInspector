//
//  O2OMethodTrace.h
//  O2O
//
//  Created by lingwan on 10/14/15.
//  Copyright © 2015 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class O2OMethodTraceInputView;

#define o2oSwizzlePrefix @"o2oSwizzlePrefix"
typedef void(^showTracedResult)(NSString *stack, NSString *statistic);

@interface O2OMethodTrace : NSObject

+ (void)traceClass:(Class)className;
+ (O2OMethodTraceInputView *)inputView;

@end
