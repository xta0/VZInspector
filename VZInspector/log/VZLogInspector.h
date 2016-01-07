//
//  VZLogInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-12-16.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kVZDefaultNumberOfLogs 20



@interface VZLogInspector : NSObject

+ (instancetype) sharedInstance;

+ (void)setNumberOfLogs:(NSUInteger)num;

+ (NSArray* )logs;

+ (NSAttributedString* )logsString;


@end
