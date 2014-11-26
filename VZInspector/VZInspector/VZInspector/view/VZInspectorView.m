//
//  VZInspectorView.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import "VZInspectorView.h"

@implementation VZInspectorView

- (id)initWithFrame:(CGRect)frame parentViewController:(UIViewController* )controller
{
    self.parentViewController = controller;
    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    return self;
}

@end
