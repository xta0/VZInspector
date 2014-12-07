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
#import "VZOverviewInspector.h"
#import "NSObject+VZInspector.h"
#import <objc/runtime.h>

@interface VZInspectorOverview()

@property(nonatomic,strong) VZNetworkInspectorOverView* httpView;
@property(nonatomic,strong) VZMemoryInspectorOverView* memoryView;
@property(nonatomic,strong) UITextView* infoView;

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
        
        
        CGRect infoFrame;
        infoFrame.origin = CGPointMake(0, networkFrame.origin.y + networkFrame.size.height);
        infoFrame.size.width = width;
        infoFrame.size.height = frame.size.height - infoFrame.origin.y;
  
        _infoView = [[UITextView alloc] initWithFrame:CGRectInset(infoFrame, 10, 10)];
        _infoView.font = [UIFont fontWithName:@"Courier-Bold" size:14];
        _infoView.textColor = [UIColor orangeColor];
        _infoView.indicatorStyle = 0;
        _infoView.editable = NO;
        _infoView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _infoView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
       // _infoView.backgroundColor = [UIColor clearColor];
        [self addSubview:_infoView];
        
        if ([VZOverviewInspector sharedInstance].observingCallback) {
            
            NSString* result = [VZOverviewInspector sharedInstance].observingCallback();
            _infoView.text = result;
    
        }
        
    }
    return self;
}

- (void)updateGlobalInfo
{
    if ([VZOverviewInspector sharedInstance].observingCallback) {
        
        NSString* result = [VZOverviewInspector sharedInstance].observingCallback();
        _infoView.text = result;
        
    }
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

- (void)close:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onClose)];
#pragma clang pop
}




@end
