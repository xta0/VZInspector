//
//  VZInspectorObjectView.m
//  VZInspector
//
//  Created by moxin on 15/5/20.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZInspectorHeapObjectView.h"

@implementation VZInspectorHeapObjectView

- (id)initWithFrame:(CGRect)frame data:(id)obj
{
    self = [super initWithFrame:frame data:obj];
    
    if (self) {
     
        self.title = @"Object Reference Graph";
        
    }
    return self;
}

@end
