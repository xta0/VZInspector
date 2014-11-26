//
//  VZInspectController.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import "VZInspector.h"
#import "VZInspectController.h"

#import "VZInspectorWindow.h"
#import "VZInspectorOverlay.h"

#import "VZInspectorLogView.h"
#import "VZInspectorCrashView.h"
#import "VZInspectorSettingView.h"
#import "VZInspectorConsoleView.h"
#import "VZInspectorGridView.h"
#import "VZInspectorSandBoxRootView.h"
#import "VZInspectorOverview.h"

#import "VZCrashInspector.h"

#import "UIWindow+VZInspector.h"
#import "NSObject+VZInspector.h"

@interface VZInspectController()

@property(nonatomic,strong) NSTimer* readHeartBeat;
@property(nonatomic,strong) NSTimer* writeHeartBeat;
@property(nonatomic,strong) VZInspectorOverview* overview;
@property(nonatomic,strong) VZInspectorLogView* logView;
@property(nonatomic,strong) VZInspectorCrashView* crashView;
@property(nonatomic,strong) VZInspectorSettingView* settingView;
@property(nonatomic,strong) VZInspectorConsoleView* consoleView;
@property(nonatomic,strong) VZInspectorGridView* gridView;
@property(nonatomic,strong) VZInspectorSandBoxRootView* sandboxView;

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
    // Do any additional setup after loading the view.

    [[VZCrashInspector sharedInstance] install];
    
    self.currentIndex = 0;
    
    //create four views:
    
    //1,overview
    self.overview = [[VZInspectorOverview alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40) parentViewController:self];
    
    //2,logview
    self.logView = [[VZInspectorLogView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40) parentViewController:self];

    //3.sandboxview
    self.sandboxView = [[VZInspectorSandBoxRootView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40) parentViewController:self];
    
    //4,settingsview
    self.settingView = [[VZInspectorSettingView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40) parentViewController:self];
    
    //5,consoleview
    self.consoleView = [[VZInspectorConsoleView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40) parentViewController:self];
    
    //6,gridview
    self.gridView = [[VZInspectorGridView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) parentViewController:self];
    
    //7,inspector
    
    [self.view addSubview:self.overview];
    self.currentView = self.overview;
    
    
    //4:tab
    for (int i=0; i<4; i++) {
        
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        int w = screenBounds.size.width/4;
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(w*i, self.view.frame.size.height-40, w, 40)];
        btn.tag = i+10;
        btn.backgroundColor = [UIColor darkGrayColor];
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 2.0f;
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onBtnClikced:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i==0) {
            [btn setTitle:@"APP状态" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        }
        if (i==1) {
            [btn setTitle:@"请求Log" forState:UIControlStateNormal];
        }
        if (i==2) {
            [btn setTitle:@"沙盒文件" forState:UIControlStateNormal];
        }
        if (i==3) {
            [btn setTitle:@"环境切换" forState:UIControlStateNormal];
        }
        [self.view addSubview:btn];
    }
    
    
    
    int w = self.overview.bounds.size.width;
    int h = self.overview.bounds.size.height;
    
    //关闭
    UIButton* closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(w-50, h-50, 40, 40)];
    closeBtn.tag = 100;
    closeBtn.backgroundColor = [UIColor darkGrayColor];
    closeBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    closeBtn.layer.borderWidth = 2.0f;
    closeBtn.layer.cornerRadius = 20.0f;
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    //closeBtn.titleLabel.textColor = [UIColor orangeColor];
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    [self.overview addSubview:closeBtn];
    
    
    //Refresh
    UIButton* refreshBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, h-50, 40, 40)];
    refreshBtn.tag = 101;
    refreshBtn.alpha = 0.6;
    refreshBtn.backgroundColor = [UIColor darkGrayColor];
    refreshBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    refreshBtn.layer.borderWidth = 2.0f;
    refreshBtn.layer.cornerRadius = 20.0f;
    refreshBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
    [refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [refreshBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [refreshBtn addTarget:self action:@selector(onUpdate) forControlEvents:UIControlEventTouchUpInside];
    [self.overview addSubview:refreshBtn];
    
    //console
    UIButton* consoleBtn = [[UIButton alloc]initWithFrame:CGRectMake(60, h-50, 40, 40)];
    consoleBtn.tag = 102;
    consoleBtn.alpha = 0.6;
    consoleBtn.backgroundColor = [UIColor darkGrayColor];
    consoleBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    consoleBtn.layer.borderWidth = 2.0f;
    consoleBtn.layer.cornerRadius = 20.0f;
    consoleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [consoleBtn setTitle:@"命令" forState:UIControlStateNormal];
    [consoleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [consoleBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [consoleBtn addTarget:self action:@selector(onConsole) forControlEvents:UIControlEventTouchUpInside];
    [self.overview addSubview:consoleBtn];
    
    //Grid
    UIButton* gridBtn = [[UIButton alloc]initWithFrame:CGRectMake(110, h-50, 40, 40)];
    gridBtn.tag = 103;
    gridBtn.alpha = 0.6;
    gridBtn.backgroundColor = [UIColor darkGrayColor];
    gridBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    gridBtn.layer.borderWidth = 2.0f;
    gridBtn.layer.cornerRadius = 20.0f;
    gridBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [gridBtn setTitle:@"网格" forState:UIControlStateNormal];
    [gridBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [gridBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [gridBtn addTarget:self action:@selector(onGrid) forControlEvents:UIControlEventTouchUpInside];
    [self.overview addSubview:gridBtn];
    
    //inspector
    UIButton* inspectorBtn = [[UIButton alloc]initWithFrame:CGRectMake(160, h-50, 40, 40)];
    inspectorBtn.tag = 104;
    inspectorBtn.alpha = 0.6;
    inspectorBtn.backgroundColor = [UIColor darkGrayColor];
    inspectorBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    inspectorBtn.layer.borderWidth = 2.0f;
    inspectorBtn.layer.cornerRadius = 20.0f;
    inspectorBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [inspectorBtn setTitle:@"UI" forState:UIControlStateNormal];
    [inspectorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [inspectorBtn addTarget:self action:@selector(onInspector:) forControlEvents:UIControlEventTouchUpInside];
    [self.overview addSubview:inspectorBtn];
    
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
    
    if (self.currentView == self.gridView) {
        
        if (pt.y < 20) {
            return NO;
        }
        else
            return YES;
    }
    else if (self.currentView == self.logView
             ||self.currentView == self.sandboxView //self.currentView == self.crashView
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
    
    for (UIView* v in self.view.subviews) {
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
            
            UIViewAnimationOptions op = 0<<20;
            if(self.currentView == self.gridView ||
               self.currentView == self.consoleView)
                op =UIViewAnimationOptionTransitionFlipFromRight;
            
            else
                op = UIViewAnimationOptionTransitionCrossDissolve;
            
            [UIView transitionFromView:self.currentView toView:self.overview duration:0.4 options:op completion:^(BOOL finished) {
                
                [sender setTitle:@"APP状态" forState:UIControlStateNormal];
                [self.currentView removeFromSuperview];
                [self.view addSubview:self.overview];
                [self.overview updateGlobalInfo];
                self.currentView = self.overview;
                self.currentIndex = 0;
                
                for (UIView* v in self.view.subviews) {
                    if (v.tag >= 10 && v.tag <= 20) {
                        v.hidden = NO;
                    }
                }
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
                [self.view addSubview:self.logView];
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
            [UIView transitionFromView:self.currentView toView:self.sandboxView duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
                
                [self.currentView removeFromSuperview];
                [self.view addSubview:self.sandboxView];
                self.currentView = self.sandboxView;
                self.currentIndex = 2;
            }];
            
            break;
        }
        case 13:
        {
            [UIView transitionFromView:self.currentView toView:self.settingView duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
                
                [self.currentView removeFromSuperview];
                [self.view addSubview:self.settingView];
                self.currentView = self.settingView;
                self.currentIndex = 3;
            }];
            
            break;
        }
        default:
            break;
    }
    
}


//
- (void)onClose
{
    [self stop];
    [VZInspector hide];
}
- (void)onUpdate
{
    [self.overview updateGlobalInfo];
}
//
- (void)onConsole
{
    [UIView transitionFromView:self.currentView toView:self.consoleView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        
        [self.currentView removeFromSuperview];
        [self.view addSubview:self.consoleView];
        self.currentView = self.consoleView;
        self.currentIndex = -1;
        
        UIButton* btn = (id)[self.view viewWithTag:10];
        [btn setTitle:@"Console" forState:UIControlStateNormal];
    }];
}

- (void)onGrid
{
    
    [UIView transitionFromView:self.currentView toView:self.gridView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        
        [self.currentView removeFromSuperview];
        [self.view addSubview:self.gridView];
        self.currentView = self.gridView;
        self.currentIndex = -1;
        
        //        UIButton* btn = (id)[self.view viewWithTag:10];
        //        [btn setTitle:@"Grid" forState:UIControlStateNormal];
        
        for (UIView* subView in self.view.subviews) {
            
            if (subView.tag >= 10 && subView.tag < 20) {
                subView.hidden = YES;
            }
        }
    }];
}

- (void)onInspector:(UIButton* )btn
{
    if ([UIWindow isSwizzled]) {
        [UIWindow swizzle:NO];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    else
    {
        [UIWindow swizzle:YES];
        [self onClose];
    }
}




@end
