//
//  VZInspectController.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
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

static NSString* vz_tracking_classPrefix;
static const int kBusinessViewTag = 999;

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

//border
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,assign) float borderWidth;
@end

@implementation VZInspectController

- (UIView* )topView
{
    return self.currentView;
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
    
//fake
//    [self.contentView addSubview:self.overview];
//    self.currentView = self.overview;
    [self.contentView addSubview:self.consoleView];
    self.currentView = self.consoleView;
    

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
    //NSLog(@"[%@]-->dealloc",self.class);
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
             ||self.currentView.class == [VZInspectorConsoleView class]
             )
    {
        return NO;
    }
    else if (self.currentView == self.overview)
    {
        if (pt.y > h-40) {
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
        else if (pt.y > h-40 ) {
            return NO;
        }
        else
            return YES;
    }
    else
    {
        if (pt.y > h-40 ) {
            return NO;
        }
        else
            return YES;
    }
    
}

+ (void)setClassPrefixName:(NSString* )name
{
    vz_tracking_classPrefix = name;
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
        self.currentIndex = 2;
        
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

- (void)showBorder:(NSNumber *)status
{
    if (status.integerValue == 0) {
        self.borderWidth = 0.5f;
        [self updateBorderOfViewHierarchy];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateBorderOfViewHierarchy) userInfo:nil repeats:YES];
    }
    else {
        [self.timer invalidate];
        self.borderWidth = 0;
        [self updateBorderOfViewHierarchy];
    }
}

- (void)updateBorderOfViewHierarchy {
    UIViewController *currentVC = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        currentVC = nextResponder;
    else
        currentVC = window.rootViewController;

    [self drawBorderOfViewHierarchy:currentVC.view withWidth:self.borderWidth];
}

- (void)drawBorderOfViewHierarchy:(UIView *)view withWidth:(CGFloat)width {
    if (view.tag == kBusinessViewTag) {
        if (width == 0) {
            //remove class name imageview
            [view removeFromSuperview];
        }
        return;
    }
    
    view.layer.borderWidth = width;
    view.layer.borderColor = [UIColor orangeColor].CGColor;
    
    //draw business view's class name
    const char* clzname = object_getClassName(view);
    [self drawClassName:clzname withWidth:width onView:view];
  
    //draw business view controller's class name
    if ([view.nextResponder isKindOfClass:[UIViewController class]]) {
        clzname = object_getClassName(view.nextResponder);
        [self drawClassName:clzname withWidth:width onView:view];
    }

    [view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [self drawBorderOfViewHierarchy:subview withWidth:width];
    }];
}

- (void)drawClassName:(const char*)clzname withWidth:(CGFloat)width onView:(UIView *)view {
    if (vz_isTrackingObject(clzname))
    {
        view.layer.borderColor = [UIColor greenColor].CGColor;
        view.layer.borderWidth = width * 2;
        BOOL flag = (view.subviews.count != 0) && (((UIView *)view.subviews[0]).tag == kBusinessViewTag);
        if (!flag) {
            const int padding = 2;
            
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 2.0);
            NSDictionary* stringAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:10], NSForegroundColorAttributeName : [UIColor greenColor]};
            NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithUTF8String:clzname] attributes:stringAttrs];
            [attrStr drawAtPoint:CGPointMake(padding, padding)];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.tag = kBusinessViewTag;
            imageView.backgroundColor = [UIColor clearColor];
            [view addSubview:imageView];
        }
    }
}

static inline bool vz_isTrackingObject(const char* className)
{
    bool ret = false;
    NSString* clznameStr = [NSString stringWithUTF8String:className];
    
    if ([clznameStr hasPrefix:vz_tracking_classPrefix]) {
        ret = true;
    }
    
    if([clznameStr isEqualToString:@"NSAutoreleasePool"])
    {
        ret = false;
    }
    
    return ret;
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