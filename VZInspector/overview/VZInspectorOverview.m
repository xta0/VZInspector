//
//  VZInspectorOverview.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspectorOverview.h"
#import "VZMemoryInspectorOverView.h"
#import "VZNetworkInspectorOverView.h"
#import "VZMemoryInspector.h"
#import "VZCPUInspectorOverView.h"
#import "VZInspectorTimer.h"
#import "VZOverviewInspector.h"
#import "NSObject+VZInspector.h"
#import "VZBorderInspector.h"
#import <objc/runtime.h>

@interface VZInspectorOverview()

@property(nonatomic,strong) VZNetworkInspectorOverView* httpView;
@property(nonatomic,strong) VZMemoryInspectorOverView* memoryView;
@property(nonatomic,strong) VZCPUInspectorOverView* cpuView;
@property(nonatomic,strong) UITextView* infoView;
@property(nonatomic,strong) UIButton* refreshBtn;

@end


@implementation VZInspectorOverview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
//        CGFloat height = 100;
        CGFloat width = self.frame.size.width;
        
        
        //total memory
        CGRect memoryFrame;
        memoryFrame.origin      = CGPointZero;
        memoryFrame.size.width  = width;
        memoryFrame.size.height = 65;
        
        _memoryView = [[VZMemoryInspectorOverView alloc] initWithFrame:memoryFrame];
        [self addSubview:_memoryView];
        
        //cpu usage
        CGRect cpuFrame;
        cpuFrame.origin      = CGPointMake(0, memoryFrame.size.height - 1);;
        cpuFrame.size.width  = width;
        cpuFrame.size.height = 65;
        
        _cpuView = [[VZCPUInspectorOverView alloc] initWithFrame:cpuFrame];
        [self addSubview:_cpuView];
        
        //network
        CGRect networkFrame;
        networkFrame.origin = CGPointMake(0, memoryFrame.size.height + cpuFrame.size.height - 2);
        networkFrame.size.width = width;
        networkFrame.size.height = 65;
        
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
        [self addSubview:_infoView];
        
        _refreshBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(_infoView.bounds) - 54, CGRectGetHeight(_infoView.bounds)-54, 44, 44)];
        _refreshBtn.layer.cornerRadius = 22;
        _refreshBtn.layer.masksToBounds = true;
        _refreshBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        _refreshBtn.layer.borderWidth = 2.0f;
        [_refreshBtn setTitle:@"R" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(updateGlobalInfo) forControlEvents:UIControlEventTouchUpInside];
        [_infoView addSubview:_refreshBtn];
        
        if ([VZOverviewInspector sharedInstance].observingCallback) {
            
            NSString* result = [VZOverviewInspector sharedInstance].observingCallback();
            _infoView.text = result;
    
        }
        
        //start timer
        __weak typeof(self) weakSelf = self;
        [VZInspectorTimer sharedInstance].readCallback = ^{

            [weakSelf handleRead];
        };
        
        [VZInspectorTimer sharedInstance].writeCallback = ^{
        
            
            [weakSelf handleWrite];
        };

    }
    return self;
}

- (void)dealloc
{
    [[VZInspectorTimer sharedInstance] stopTimer];
}

- (void)updateGlobalInfo
{
    if ([VZOverviewInspector sharedInstance].observingCallback) {
        
        NSString* result = [VZOverviewInspector sharedInstance].observingCallback();
        _infoView.text = result;
        
    }
}

- (void)startTimer
{
    [[VZInspectorTimer sharedInstance] startTimer];
}

- (void)stopTimer
{
    [[VZInspectorTimer sharedInstance] stopTimer];
}


- (void)handleRead
{
    [self.memoryView handleRead];
    [self.cpuView handleRead];
    [self.httpView handleRead];
    
    if (self.memoryWarning) {
        
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
- (void)handleWrite
{
    [self.memoryView handleWrite];
    [self.cpuView handleWrite];
    [self.httpView handleWrite];
}


- (void)close:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onClose)];
#pragma clang pop
}




@end
