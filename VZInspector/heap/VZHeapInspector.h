//
//  VZHeapInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface VZHeapObject:NSObject
//
//@property(nonatomic,strong)id object;
//@property(nonatomic,strong)NSString* address;
//
//@end

typedef struct
{
    Class isa;
    
}VZ_Object;

@interface VZHeapInspector : NSObject

+ (NSString* )classPrefixName;
+ (void)setClassPrefixName:(NSString* )name;
+ (NSSet* )livingObjectsWithClassPrefix:(NSString* )prefix;
+ (NSSet* )livingObjects;


@end
