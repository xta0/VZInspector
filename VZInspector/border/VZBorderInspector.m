//
//  VZBorderInspector.m
//  VZInspector
//
//  Created by lingwan on 15/4/16.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZBorderInspector.h"
#import "VZInspectorTimer.h"
#import <UIKit/UIKit.h>


@interface NSTimer(VZBorderInspector)
+(NSTimer* )scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void(^)())block userInfo:(id)userInfo repeats:(BOOL)repeat;
@end

@implementation NSTimer(VZBorderInspector)

+ (NSTimer* )scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void (^)())block userInfo:(id)userInfo repeats:(BOOL)repeat
{
    return [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(onTimerFired:) userInfo:[block copy] repeats:repeat];
}

+ (void)onTimerFired:(NSTimer* )timer
{
    void(^block)() = timer.userInfo;
    
    if (block) {
        block();
    }
}

@end

@interface VZBorderItem:NSObject

@property(nonatomic,weak) UIView* view;
@property(nonatomic,assign) CGFloat borderWidth;
@property(nonatomic,assign) CGColorRef borderColor;


@end

@implementation VZBorderItem
@end

@interface VZBorderInspector ()
{
    BOOL _on;
    NSMutableSet* _set;
}

@property(nonatomic,strong) NSTimer* timer;
@property(nonatomic,strong) NSString* prefixName;
@property(nonatomic,assign) float borderWidth;


@end

@implementation VZBorderInspector

+ (instancetype)sharedInstance {
    static VZBorderInspector *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [VZBorderInspector new];
        }
    });
    
    return instance;
}

+ (void)setViewClassPrefixName:(NSString* )name
{
    [[self sharedInstance] setPrefixName:name];
}

- (BOOL)isON
{
    return _on;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        _borderWidth = 0.5;
        _set = [NSMutableSet new];

    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showBorder
{
    _on = !_on;
    
    if (_on) {
        
        __weak typeof(self) weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 block:^{
            
            [weakSelf timerTriggered];
            
        } userInfo:nil repeats:YES];
    }
    else
    {
        [self.timer invalidate];
        self.timer = nil;
        [self timerStopped];
    }
}

- (void)showViewClassName
{
    //todo...
}

- (void)timerTriggered
{
    if (_on)
    {
        [self recoverViewBorder];
        [_set removeAllObjects];
        [self updateBorderOfViewHierarchy];
    }
}

- (void)timerStopped
{
    if (!_on)
    {
        [self recoverViewBorder];
        [_set removeAllObjects];
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
    
    [self drawBorderOfViewHierarchy:currentVC.view];
}

- (void)drawBorderOfViewHierarchy:(UIView *)view {
    
    //all border
    VZBorderItem* item = [VZBorderItem new];
    item.borderColor = view.layer.borderColor;
    item.borderWidth = view.layer.borderWidth;
    item.view = view;
    [_set addObject:item];
    
    view.layer.borderWidth = self.borderWidth;
    view.layer.borderColor = [UIColor orangeColor].CGColor;
    
    NSString* className = NSStringFromClass([view class]);
    if (self.prefixName.length > 0 ) {
        
        if ([className hasPrefix:self.prefixName]) {
         
            if ([view viewWithTag:100]) {
                
                UILabel* label = (UILabel* )[view viewWithTag:100];
                label.text = className;
            }
            else
            {
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 12)];
                label.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
                label.textAlignment = NSTextAlignmentLeft;
                label.text = className;
                label.textColor = [UIColor cyanColor];
                label.font = [UIFont systemFontOfSize:9.0];
                label.tag = 100;
                [view addSubview:label];
            }
            
        }
    }
    for (UIView* subview in view.subviews)
    {
        if (subview.tag == 100) {
            continue;
        }
        [self drawBorderOfViewHierarchy:subview];
    }
}

- (void)recoverViewBorder
{
    [_set enumerateObjectsUsingBlock:^(VZBorderItem* obj, BOOL *stop) {
        
        if (obj.view)
        {
            [[obj.view viewWithTag:100] removeFromSuperview];
            obj.view.layer.borderWidth = obj.borderWidth;
            obj.view.layer.borderColor = obj.borderColor;
        }
    }];
}





@end
