//
//  VZHeapInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZHeapInspector : NSObject

+ (NSString* )classPrefixName;
+ (void)setClassPrefixName:(NSString* )name;
+ (NSSet* )livingObjectsWithClassPrefix:(NSString* )prefix;


@end
