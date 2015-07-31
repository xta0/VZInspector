//
//  VZInspectorHeapRootView.m
//  VZInspector
//
//  Created by moxin on 15/5/20.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZInspectorHeapRootView.h"
#import "VZInspectorHeapListView.h"


@interface VZInspectorHeapHeaderView : UIView

@property(nonatomic,strong) UILabel* textLabel;
@property(nonatomic,strong) UIButton* backBtn;
@property(nonatomic,weak) id delegate;

@end

@implementation VZInspectorHeapHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 13, frame.size.width, 18)];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:18.0f];
        [self addSubview:self.textLabel];
        
        self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 44, 44)];
        self.backBtn.backgroundColor = [UIColor clearColor];
        [self.backBtn setTitle:@"<-" forState:UIControlStateNormal];
        [self.backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.backBtn addTarget:self.delegate action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
        [self addSubview:self.backBtn];
    }
    return self;
}

@end



@interface VZInspectorHeapRootView()

@property(nonatomic,strong)NSMutableArray* stack;
@property(nonatomic,strong)VZInspectorHeapHeaderView* headerView;
@property(nonatomic,strong)VZInspectorHeapSubView* currentView;


@end


@implementation VZInspectorHeapRootView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.stack      = [NSMutableArray new];
        self.headerView = [[VZInspectorHeapHeaderView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        self.headerView.delegate = self;
        [self addSubview:self.headerView];
        
        [self loadRootView];
        
    }
    return self;
}

- (void)loadRootView
{
    
    VZInspectorHeapListView* rootView = [[VZInspectorHeapListView alloc]initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height-44)];
    rootView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
    rootView.layer.borderWidth = 2.0f;
    rootView.delegate = self;
    
    
    [self.stack addObject:rootView];
    [self addSubview:rootView];
    self.currentView = rootView;
    self.headerView.textLabel.text = @"Alived Objects on Heap";
    
}

- (void)push:(NSString* )clsName object:(id)data;
{
    VZInspectorHeapSubView* targetView = (VZInspectorHeapSubView* )[[NSClassFromString(clsName) alloc]initWithFrame:CGRectMake(self.frame.size.width, 44, self.frame.size.width, self.frame.size.height-44) data:data];
    targetView.delegate = self;

    [self addSubview:targetView];
    VZInspectorHeapSubView* currentView = self.currentView;
    
    [self.currentView subViewWillDisappear];
    [UIView animateWithDuration:0.4 animations:^{
        
        currentView.alpha = 0.0f;
        currentView.frame = CGRectMake(-CGRectGetWidth(currentView.bounds), 44, CGRectGetWidth(currentView.bounds), CGRectGetHeight(currentView.bounds));
        
        targetView.frame = CGRectMake(0, 44, CGRectGetWidth(targetView.bounds), CGRectGetHeight(targetView.bounds));
        targetView.alpha = 1.0f;
       
        
    } completion:^(BOOL finished) {
        
        
        [self.stack addObject:targetView];
        currentView.frame = CGRectMake(0, 0, CGRectGetWidth(currentView.bounds), CGRectGetHeight(currentView.bounds));
        self.currentView = targetView;
         [targetView subViewWillAppear];
        self.headerView.textLabel.text = self.currentView.title;
    }];
    
}

- (void)pop
{
    if (self.stack.count <2) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.parentViewController performSelector:@selector(onBack)];
#pragma clang diagnostic pop
        
    }
    else
    {
        VZInspectorHeapSubView* currentView = self.currentView;
        currentView.alpha = 1.0f;
        
        VZInspectorHeapSubView* belowView = self.stack[self.stack.count - 2];
        belowView.alpha = 0.0f;
        
        belowView.frame = CGRectMake(-CGRectGetWidth(belowView.bounds), 44, CGRectGetWidth(belowView.bounds), CGRectGetHeight(belowView.bounds));
        
        [currentView subViewWillDisappear];
        [UIView animateWithDuration:0.4 animations:^{
            
            currentView.frame = CGRectMake(self.frame.size.width, 44, CGRectGetWidth(currentView.bounds), CGRectGetHeight(currentView.bounds));
            currentView.alpha = 0.0f;
            
            belowView.frame = CGRectMake(0, 44,CGRectGetWidth(belowView.bounds), CGRectGetHeight(belowView.bounds));
            belowView.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            
            
            [self.stack removeObject:currentView];
            [currentView removeFromSuperview];
            self.currentView = belowView;
            [belowView subViewWillAppear];
            self.headerView.textLabel.text = self.currentView.title;
            
            
        }];
    }
}




@end
