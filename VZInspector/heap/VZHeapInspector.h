//
//  VZHeapInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct
{
    Class isa;
    
}VZ_Object;

typedef void (^VZHeapInspectorEnumeratorBlock)(__unsafe_unretained id obj, __unsafe_unretained Class clz);

@interface VZHeapInspector : NSObject

+ (NSString* )classPrefixName;
+ (void)setClassPrefixName:(NSString* )name;
+ (NSSet* )livingObjectsWithClassPrefix:(NSString* )prefix;
+ (NSMutableArray* )livingObjects;
+ (void)startTrackingHeapObjects:(VZHeapInspectorEnumeratorBlock)block;



@end
