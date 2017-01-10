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
#import "VZInspectorResource.h"
#import "VZInspectorOverlay.h"
#import "VZInspectorLogView.h"
#import "VZInspectorSettingView.h"
#import "VZInspectorToolboxView.h"
#import "VZInspectorGridView.h"
#import "VZInspectorSandBoxRootView.h"
#import "VZInspectorOverview.h"
#import "VZInspectorNetworkHistoryView.h"
#import "UIWindow+VZInspector.h"
#import "NSObject+VZInspector.h"
#import "VZBorderInspector.h"
#import "VZInspectorTimer.h"
#import "VZInspectorImageInfoView.h"
#import "VZInspectorLocationView.h"
#import "VZFrameRateOverlay.h"
#import "VZDesignDraftView.h"
#import "VZInspectorColorPickerView.h"
#import "VZInspectorCrashRootView.h"
#import "VZInspectorMermoryManager.h"
#import "VZInspectorMermoryUtil.h"


#define kVZInspectorCloseButtonTitle @"Close"
#define kVZInspectorTabBarHeight 40


@interface VZInspectController()

@property(nonatomic,strong) UIView* contentView;
@property(nonatomic,strong) VZInspectorOverview* overview;
@property(nonatomic,strong) VZInspectorLogView* logView;
@property(nonatomic,strong) NSDictionary* views;

@property(nonatomic,strong,readwrite) UIView* currentView;

@property (nonatomic, strong) VZInspectorToolItem *mermoryCheckItem;

@end

@implementation VZInspectController

- (UIView* )topView
{
    return _currentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //create content view
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    self.contentView.userInteractionEnabled = YES;
    [self.view addSubview:self.contentView];
    
    //create views:
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-kVZInspectorTabBarHeight);
    
    //1,overview
    self.overview = [[VZInspectorOverview alloc]initWithFrame:rect parentViewController:self.parentViewController];
    _currentView = self.overview;
    
    //2,logview
    self.logView = [[VZInspectorLogView alloc]initWithFrame:rect parentViewController:self];
    
    //3,toolboxView
    self.toolboxView = [[VZInspectorToolboxView alloc]initWithFrame:rect parentViewController:self];
    [self registerBuiltinTools];
    
    //4,plugin
    self.pluginView = [[VZInspectorToolboxView alloc]initWithFrame:rect parentViewController:self];
    [self.pluginView setIcon:[VZInspectorResource pluginIcon]];
    [self registerAdditionTools];
    
    
    self.views = @{
                   @"Status":self.overview,
                   @"Log":self.logView,
                   @"Toolbox":self.toolboxView,
                   @"Plugin":self.pluginView
                   };
    
    //5,tab
    NSArray<NSString *> *titles = [@[@"Status", @"Log", @"Toolbox", @"Plugin"] arrayByAddingObject:kVZInspectorCloseButtonTitle];
    int w = [UIScreen mainScreen].bounds.size.width / titles.count;
    
    for (int i=0; i<titles.count; i++) {
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(w*i, self.view.frame.size.height-kVZInspectorTabBarHeight, w, kVZInspectorTabBarHeight)];
        btn.backgroundColor = [UIColor darkGrayColor];
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 2.0f;
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onBtnClikced:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [self.contentView addSubview:btn];
        
        if (i == 0) {
            [self onBtnClikced:btn];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMermoryCheckStatus) name:KVZInspectorMermoryCheckStatusChange object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    //NSLog(@"[%@]-->dealloc",self.class);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public API
//
- (void)start
{
    [self.overview updateGlobalInfo];
    [self.overview startTimer];
    
}

- (void)stop
{
    [self.overview stopTimer];
}

- (void)onClose
{
    [self stop];
    [VZInspector hide];
}

- (BOOL)canTouchPassThrough:(CGPoint)pt
{
    int w = self.view.bounds.size.width;
    int h = self.view.bounds.size.height;
    
    if ([_currentView isKindOfClass:[VZInspectorView class]]) {
        return [(VZInspectorView *)_currentView canTouchPassThrough:pt];
    }
    else {
        return pt.y < h-kVZInspectorTabBarHeight;
    }
}

- (void)transitionToView:(UIView *)view
{
    __weak typeof(self) weakSelf = self;
    [UIView transitionFromView:self.contentView toView:view duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        weakSelf.currentView = view;
    }];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private API

//tab clicked:
- (void)onBtnClikced:(UIButton* )sender
{
    NSString *title = sender.currentTitle;
    if ([kVZInspectorCloseButtonTitle isEqualToString:title]) {
        [self onClose];
        return;
    }
    else if (![_currentTab isEqualToString:title]) {
        for (UIView* v in self.contentView.subviews) {
            if ([v isKindOfClass:[UIButton class]]) {
                UIButton* btn = (UIButton* )v;
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
        
        [sender setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        
        UIView *view = self.views[title];
        [UIView transitionFromView:_currentView toView:view duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            
            [self.contentView addSubview:view];
            _currentView = view;
            _currentTab = title;
        }];
    }
}

- (void)onBack
{
    [UIView transitionFromView:_currentView toView:self.contentView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
        _currentView = self.views[_currentTab];
    }];
}

- (void)registerBuiltinTools {
    [self.toolboxView addToolItem:[VZInspectorToolItem itemWithName:@"Logs" icon:[VZInspectorResource network_logs] callback:^{
        VZInspectorNetworkHistoryView* networkView = [[VZInspectorNetworkHistoryView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) parentViewController:self];
        [self transitionToView:networkView];
    }]];
    [self.toolboxView addToolItem:[VZInspectorToolItem itemWithName:@"Crash" icon:[VZInspectorResource crash] callback:^{
        VZInspectorCrashRootView* crashView = [[VZInspectorCrashRootView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) parentViewController:self];
        [self transitionToView:crashView];
    }]];
    [self.toolboxView addToolItem:[VZInspectorToolItem itemWithName:@"SandBox" icon:[VZInspectorResource sandbox] callback:^{
        VZInspectorSandBoxRootView* sandBoxView = [[VZInspectorSandBoxRootView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) parentViewController:self];
        [self transitionToView:sandBoxView];
    }]];
    [self.toolboxView addToolItem:[VZInspectorToolItem itemWithName:@"Gird" icon:[VZInspectorResource grid] callback:^{
        VZInspectorGridView* gridView = [[VZInspectorGridView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) parentViewController:self];
        [self transitionToView:gridView];
    }]];
    [self.toolboxView addToolItem:[VZInspectorToolItem switchItemWithName:@"Border" icon:[VZInspectorResource viewClass] callback:^BOOL(BOOL on){
        [[VZBorderInspector sharedInstance] showBorder];
        [self onClose];
        return !on;
    }]];
    [self.toolboxView addToolItem:[VZInspectorToolItem switchItemWithName:@"Warning" icon:[VZInspectorResource memoryWarning] callback:^BOOL(BOOL on) {
        if (on) {
            self.overview.memoryWarning = false;
        }
        else {
            self.overview.memoryWarning = true;
        }
        return !on;
    }]];
    [self.toolboxView addToolItem:[VZInspectorToolItem itemWithName:@"Image" icon:[VZInspectorResource image] callback:^{
        VZInspectorImageInfoView *view = [[VZInspectorImageInfoView alloc] initWithFrame:self.view.bounds parentViewController:self];
        [self transitionToView:view];
    }]];
    [self.toolboxView addToolItem:[VZInspectorToolItem itemWithName:@"Location" icon:[VZInspectorResource location] callback:^{
        VZInspectorLocationView * locationView = [[VZInspectorLocationView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) parentViewController:self];
        [self transitionToView:locationView];
    }]];
    [self.toolboxView addToolItem:[VZInspectorToolItem switchItemWithName:@"FrameRate" icon:[VZInspectorResource frameRate] callback:^BOOL(BOOL on) {
        if (on) {
            [self onClose];
            [VZFrameRateOverlay stop];
        }
        else {
            [self onClose];
            [VZFrameRateOverlay start];
        }
        return !on;
    }]];
    [self.toolboxView addToolItem:[VZInspectorToolItem itemWithName:@"colorPicker" icon:[VZInspectorResource colorPickerIcon] callback:^{
        VZInspectorColorPickerView* colorPickerView = [[VZInspectorColorPickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) parentViewController:self];
        [self transitionToView:colorPickerView];
    }]];
    [self.toolboxView addToolItem:[VZInspectorToolItem itemWithName:@"Design" icon:[VZDesignDraftView icon] callback:^{
        VZDesignDraftView *draftView = [[VZDesignDraftView alloc] initWithFrame:self.view.bounds parentViewController:self];
        [self transitionToView:draftView];
    }]];
    
    _mermoryCheckItem =[VZInspectorToolItem itemWithName:@"Leak" icon:[VZInspectorMermoryManager icon] callback:^{
        [[VZInspectorMermoryManager sharedInstance] toggle];
        [self onClose];
    }];
    

    _mermoryCheckItem.status = [self mermoryCheckStatus] ?@"ON":nil;

    [self.toolboxView addToolItem:_mermoryCheckItem];

    
}

- (BOOL)mermoryCheckStatus{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    BOOL checkSwitch;
    if(defaults){
        checkSwitch = [[defaults objectForKey:KVZInspectorMermoryCheckSwitch] boolValue];
    }

    return checkSwitch;
}

- (void)updateMermoryCheckStatus{
    _mermoryCheckItem.status = [self mermoryCheckStatus] ?@"ON":@"OFF";

    [self.toolboxView updateCollectionView];

}

- (void)registerAdditionTools {
    for (VZInspectorToolItem *item in [VZInspector additionTools]) {
        [self.pluginView addToolItem:item];
    }
}

@end
