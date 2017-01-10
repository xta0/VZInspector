//
//  VZInspectorOverview.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspectorOverview.h"
#import "VZMemoryInspectorOverView.h"
#import "VZMemoryInspector.h"
#import "VZInspectorTimer.h"
#import "VZOverviewInspector.h"
#import "NSObject+VZInspector.h"
#import "VZBorderInspector.h"
#import "VZInspectorSettingView.h"
#import "VZControllerStack.h"

#import <objc/runtime.h>

@interface VZInspectorOverview()

@property(nonatomic,strong) VZMemoryInspectorOverView* memoryView;
@property(nonatomic, strong) VZInspectorSettingView* settingView;
@property(nonatomic,strong) UITextView* infoView;
@property(nonatomic,strong) UIButton* refreshBtn;

@end


@implementation VZInspectorOverview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = self.frame.size.width;
        
        //envView
        CGRect envFrame;
        envFrame.origin         = CGPointMake(0, 10);
        envFrame.size.width     = width;
        envFrame.size.height    = [VZInspectorSettingView heightForEnvButtons];
        _settingView = [[VZInspectorSettingView alloc]initWithFrame:CGRectInset(envFrame, 10, 0) parentViewController:self.parentViewController];
        [self addSubview:_settingView];
        
        //total memory
        CGRect memoryFrame;
        memoryFrame.origin      = CGPointMake(0, CGRectGetMaxY(_settingView.frame) + 10);
        memoryFrame.size.width  = width;
        memoryFrame.size.height = 65;
        
        _memoryView = [[VZMemoryInspectorOverView alloc] initWithFrame:memoryFrame];
        [self addSubview:_memoryView];
        
        //infoView
        CGRect infoFrame;
        infoFrame.origin        = CGPointMake(0, CGRectGetMaxY(_memoryView.frame) - 1);
        infoFrame.size.width    = width;
        infoFrame.size.height   = frame.size.height - infoFrame.origin.y;
  
        _infoView = [[UITextView alloc] initWithFrame:CGRectInset(infoFrame, 10, 10)];
        _infoView.font = [UIFont fontWithName:@"Courier-Bold" size:14];
        _infoView.textColor = [UIColor orangeColor];
        _infoView.indicatorStyle = 0;
        _infoView.editable = NO;
        _infoView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _infoView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        [self addSubview:_infoView];
        
        _refreshBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_infoView.frame) - 54, CGRectGetMaxY(_infoView.frame)-54, 44, 44)];
        _refreshBtn.layer.cornerRadius = 22;
        _refreshBtn.layer.masksToBounds = true;
        _refreshBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _refreshBtn.layer.borderWidth = 2.0f;
        [_refreshBtn setTitle:@"R" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(updateGlobalInfo) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_refreshBtn];
        
        [self updateGlobalInfo];
        
        //start timer
        __weak typeof(self) weakSelf = self;
        [VZInspectorTimer sharedInstance].readCallback = ^{
            [weakSelf handleRead];
        };
        
        [VZInspectorTimer sharedInstance].writeCallback = ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:(NSString* const)kVZTimerWriteCallbackString object:nil];
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
    NSMutableString *text = [NSMutableString new];
    for (vz_overview_callback callback in [VZOverviewInspector sharedInstance].observingCallbacks) {
        [text appendString:callback()];
        [text appendString:@"\n\n"];
    }
    [text appendFormat:@"Controller堆栈:\n%@", [VZControllerStack controllerStack]];
    _infoView.text = text;
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
//    [self.cpuView handleRead];
//    [self.httpView handleRead];
    
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
//    [self.cpuView handleWrite];
//    [self.httpView handleWrite];
}


- (void)close:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onClose)];
#pragma clang pop
}




@end
