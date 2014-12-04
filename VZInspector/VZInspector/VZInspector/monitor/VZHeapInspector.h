//
//  VZHeapInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZHeapInspector : NSObject

+ (void)trackObjectsWithPrefix:(NSString* )prefix;
+ (NSSet* )livingObjects;
+ (NSSet* )livingObjectsWithPrefix;


@end
