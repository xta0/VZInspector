//
//  VZInspectController.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspector.h"
#import "VZInspectController.h"

#import "VZInspectorWindow.h"
#import "VZInspectorOverlay.h"

#import "VZInspectorLogView.h"
#import "VZInspectorCrashRootView.h"
#import "VZInspectorSettingView.h"
#import "VZInspectorConsoleView.h"
#import "VZInspectorGridView.h"
#import "VZInspectorSandBoxRootView.h"
#import "VZInspectorHeapView.h"
#import "VZInspectorOverview.h"

#import "UIWindow+VZInspector.h"
#import "NSObject+VZInspector.h"
#import "VZCrashInspector.h"


@interface VZInspectController()

@property(nonatomic,strong) NSTimer* readHeartBeat;
@property(nonatomic,strong) NSTimer* writeHeartBeat;
@property(nonatomic,strong) UIView* contentView;
@property(nonatomic,strong) VZInspectorOverview* overview;
@property(nonatomic,strong) VZInspectorLogView* logView;
@property(nonatomic,strong) VZInspectorSettingView* settingView;
@property(nonatomic,strong) VZInspectorConsoleView* consoleView;

@property(nonatomic,strong) UIView* currentView;
@property(nonatomic,assign) NSInteger currentIndex;
@property(nonatomic,assign) NSNumber* performMemoryWarning;

@end

@implementation VZInspectController

- (UIView* )topView
{
    return self.currentView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentIndex = 0;
    
    //create content view
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    self.contentView.userInteractionEnabled = YES;
    [self.view addSubview:self.contentView];
    
    //create four views:
    
    //1,overview
    self.overview = [[VZInspectorOverview alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40) parentViewController:self];
    
    //2,logview
    self.logView = [[VZInspectorLogView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40) parentViewController:self];

    //3,consoleview
    self.consoleView = [[VZInspectorConsoleView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40) parentViewController:self];
    
    //4,settingsview
    self.settingView = [[VZInspectorSettingView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40) parentViewController:self];
    

    [self.contentView addSubview:self.overview];
    self.currentView = self.overview;
    

    //4:tab
    for (int i=0; i<5; i++) {
        
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        int w = screenBounds.size.width/5;
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(w*i, self.view.frame.size.height-40, w, 40)];
        btn.tag = i+10;
        btn.backgroundColor = [UIColor darkGrayColor];
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 2.0f;
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onBtnClikced:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i==0) {
            [btn setTitle:@"Status" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        }
        if (i==1) {
            [btn setTitle:@"Log" forState:UIControlStateNormal];
        }
        if (i==2) {
            [btn setTitle:@"Console" forState:UIControlStateNormal];
        }
        if (i==3) {
            [btn setTitle:@"ENV" forState:UIControlStateNormal];
        }
        if (i==4) {
            
            [btn setTitle:@"Close" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        [self.contentView addSubview:btn];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    NSLog(@"[%@]-->dealloc",self.class);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public API

- (void)start
{
    
    
    //start timer:
    if (!_readHeartBeat) {
        _readHeartBeat = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                                          target: self
                                                        selector: @selector(handleReadHeartBeat)
                                                        userInfo: nil
                                                         repeats: YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (!_writeHeartBeat) {
                _writeHeartBeat = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                   target:self
                                                                 selector:@selector(handleWriteHeartBeat)
                                                                 userInfo:nil repeats:YES];
            }
            
        });
    }
}
- (void)stop
{
    [_readHeartBeat invalidate],_readHeartBeat = nil;
    [_writeHeartBeat invalidate],_writeHeartBeat = nil;
    
    [self.consoleView hideKeyboard];
    
}



- (BOOL)canTouchPassThrough:(CGPoint)pt
{
    //int w = self.view.bounds.size.width;
    int h = self.view.bounds.size.height;
    
    if (self.currentView.class == [VZInspectorGridView class]) {
        
        if (pt.y < 20) {
            return NO;
        }
        else
            return YES;
    }
    else if (self.currentView.class == [VZInspectorLogView class]
             ||self.currentView.class == [VZInspectorSandBoxRootView class]
             ||self.currentView.class == [VZInspectorHeapView class]
             ||self.currentView.class == [VZInspectorCrashRootView class]
             )
    {
        return NO;
    }
    else if (self.currentView == self.overview)
    {
        if (pt.y > h-90) {
            return NO;
        }
        else
            return YES;
    }
    else if (self.currentView == self.settingView)
    {
        if (pt.y < 40) {
            return NO;
        }
        else if (pt.y > h-90 ) {
            return NO;
        }
        else
            return YES;
    }
    else
    {
        if (pt.y > h-90 ) {
            return NO;
        }
        else
            return YES;
    }
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private API

- (void)handleReadHeartBeat
{
    [self.overview handleRead];
    
    if (self.performMemoryWarning.boolValue) {
        
        [self.overview performMemoryWarning:YES];
        
    }
    else
        [self.overview performMemoryWarning:NO];
}

- (void)handleWriteHeartBeat
{
    [self.overview handleWrite];
}

//tab clicked:
- (void)onBtnClikced:(UIButton* )sender
{
    
    for (UIView* v in self.contentView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton* btn = (UIButton* )v;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    [sender setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    [self.consoleView hideKeyboard];
    
    switch (sender.tag) {
        case 10:
        {
            if (self.currentIndex == 0) {
                return;
            }
            
            [UIView transitionFromView:self.currentView toView:self.overview duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
                
                [self.currentView removeFromSuperview];
                [self.contentView addSubview:self.overview];
                [self.overview updateGlobalInfo];
                self.currentView = self.overview;
                self.currentIndex = 0;

            }];
            
            break;
        }
        case 11:
        {
            
            if (self.currentIndex == 1) {
                return;
            }
            [UIView transitionFromView:self.currentView toView:self.logView duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
                
                [self.currentView removeFromSuperview];
                [self.contentView addSubview:self.logView];
                self.currentView = self.logView;
                self.currentIndex = 1;
            }];
            
            break;
        }
            
        case 12:
        {
            if (self.currentIndex == 2) {
                return;
            }
            
            [UIView transitionFromView:self.currentView toView:self.consoleView duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
               
                    [self.currentView removeFromSuperview];
                    [self.contentView addSubview:self.consoleView];
                    self.currentView = self.consoleView;
                    self.currentIndex = 2;
                
            }];
            
            break;
        }
        case 13:
        {
            [UIView transitionFromView:self.currentView toView:self.settingView duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
                
                [self.currentView removeFromSuperview];
                [self.contentView addSubview:self.settingView];
                self.currentView = self.settingView;
                self.currentIndex = 3;
            }];
            
            break;
        }
        case 14:
        {
            [self onClose];
            break;
        }
        default:
            break;
    }
    
}

- (void)onClose
{
    [self stop];
    [VZInspector hide];
}

- (void)onBack
{
    [UIView transitionFromView:self.currentView toView:self.contentView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
        
        [self.currentView removeFromSuperview];
        [self.view addSubview:self.contentView];
        [self.contentView addSubview:self.consoleView];
        
        self.currentView = self.consoleView;
        self.currentIndex = 1;
        
    }];

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - console callback

- (void)showSandBox
{
    VZInspectorSandBoxRootView* sandBoxView = [[VZInspectorSandBoxRootView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) parentViewController:self];
    
    
    [UIView transitionFromView:self.contentView toView:sandBoxView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        
        [self.contentView removeFromSuperview];
        [self.view addSubview:sandBoxView];
        self.currentView = sandBoxView;
        self.currentIndex = -1;
        
    }];
}

- (void)showGrid
{
    VZInspectorGridView* gridView = [[VZInspectorGridView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) parentViewController:self];
    
    
    [UIView transitionFromView:self.contentView toView:gridView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        
        [self.contentView removeFromSuperview];
        [self.view addSubview:gridView];
        self.currentView = gridView;
        self.currentIndex = -1;

    }];
}


- (void)showBorder
{
    if ([UIWindow isSwizzled])
    {
        [UIWindow swizzle:NO];
    }
    else
    {
        [UIWindow swizzle:YES];
        [self onClose];
    }
}

- (void)showHeap
{
    
    VZInspectorHeapView* heapView = [[VZInspectorHeapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) parentViewController:self];
    
    [UIView transitionFromView:self.contentView toView:heapView
                      duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished) {
        
        [self.contentView removeFromSuperview];
        [self.view addSubview:heapView];
        self.currentView = heapView;
        self.currentIndex = -1;
    }];

}

- (void)showCrashLogs
{
    VZInspectorCrashRootView* crashView = [[VZInspectorCrashRootView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) parentViewController:self];
    
    [UIView transitionFromView:self.contentView toView:crashView
                      duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished) {
                        
                        [self.contentView removeFromSuperview];
                        [self.view addSubview:crashView];
                        self.currentView = crashView;
                        self.currentIndex = -1;
                    }];

}




@end
