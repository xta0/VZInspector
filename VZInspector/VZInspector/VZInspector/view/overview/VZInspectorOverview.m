//
//  VZInspectorOverview.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import "VZInspectorOverview.h"
#import "VZMemoryInspectorOverView.h"
#import "VZNetworkInspectorOverView.h"
#import "VZMemoryInspector.h"
#import "NSObject+VZInspector.h"


@interface VZInspectorOverview()

@property(nonatomic,strong) VZNetworkInspectorOverView* httpView;
@property(nonatomic,strong) VZMemoryInspectorOverView* memoryView;


@end


@implementation VZInspectorOverview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        CGFloat height = 100;
        CGFloat width = self.frame.size.width;
        
        
        //total memory
        CGRect memoryFrame;
        memoryFrame.origin      = CGPointZero;
        memoryFrame.size.width  = width;
        memoryFrame.size.height = height;
        
        _memoryView = [[VZMemoryInspectorOverView alloc] initWithFrame:memoryFrame];
        [self addSubview:_memoryView];
        
        
        //network
        CGRect networkFrame;
        networkFrame.origin = CGPointMake(0, memoryFrame.size.height);
        networkFrame.size.width = width;
        networkFrame.size.height = 90;
        
        _httpView = [[VZNetworkInspectorOverView alloc]initWithFrame:networkFrame];
        [self addSubview:_httpView];
        
        
    }
    return self;
}

- (void)updateGlobalInfo
{
    
}

- (void)handleRead
{
    [self.memoryView handleRead];
    [self.httpView handleRead];
    
}
- (void)handleWrite
{
    [self.memoryView handleWrite];
    [self.httpView handleWrite];
}


- (void)performMemoryWarning:(BOOL)b
{
    
    if (b) {
        
        if (self.memoryView.backgroundColor == [[UIColor redColor] colorWithAlphaComponent:0.6f]) {
            self.memoryView.backgroundColor = [UIColor clearColor];
        }
        else
            self.memoryView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6f];
        
        
        [VZMemoryInspector performLowMemoryWarning];
    }
    else
    {
        
        self.memoryView.backgroundColor = [UIColor clearColor];
    }
    
}

- (void)toConsole:(id)sender
{
    
}

- (void)close:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onClose)];
#pragma clang pop
}



@end
