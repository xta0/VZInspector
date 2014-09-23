//
//  NSObject+VZInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (VZInspector)

/**
 for debugger use
 */
@property(nonatomic,strong) NSMutableArray* samplePoints;
/**
 for debugger use
 */
- (void)heartBeat;

@end
