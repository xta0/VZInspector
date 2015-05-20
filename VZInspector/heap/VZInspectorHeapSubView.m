//
//  VZInspectorSubView.m
//  VZInspector
//
//  Created by moxin on 15/5/20.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZInspectorHeapSubView.h"

@implementation VZInspectorHeapSubView
{
}
- (id)initWithFrame:(CGRect)frame data:(id)obj
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _obj = obj;
        
    }
    return self;
    
}

@end
