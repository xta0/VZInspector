//
//  VZBorderInspector.m
//  VZInspector
//
//  Created by lingwan on 15/4/16.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import "VZBorderInspector.h"
#import <UIKit/UIKit.h>

static NSString* vz_tracking_classPrefix;
static const int kClassNameImageViewTag = 1757;
static const int kClassNamePadding = 2;

@interface VZBorderInspector ()

@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,assign) float borderWidth;

//business view's border
@property(nonatomic,assign) BOOL showingBusinessBorder;

//show or hide status
@property(nonatomic,assign) BOOL showOrHideAllBorder;
@property(nonatomic,assign) BOOL showOrHideBusBorder;
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

+ (void)setClassPrefixName:(NSString* )name {
    vz_tracking_classPrefix = name;
}

- (void)timerTriggered
{

}
- (void)timerStopped
{

}
- (void)updateBorderWithType:(kVZBorderType)type {
    if (type == kVZBorderTypeAllView) {
        self.showOrHideAllBorder = !self.showOrHideAllBorder;
        self.showingBusinessBorder = NO;
    } else {
        self.showOrHideBusBorder = !self.showOrHideBusBorder;
        self.showingBusinessBorder = YES;
    }
    
    [self removeAllBorder];
    if ((!self.showingBusinessBorder && self.showOrHideAllBorder) || (self.showingBusinessBorder && self.showOrHideBusBorder)) {
        self.borderWidth = 0.5f;
        [self updateBorderOfViewHierarchy];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateBorderOfViewHierarchy) userInfo:nil repeats:YES];
    }
}

#pragma mark - private methods
- (void)removeAllBorder {
    [self.timer invalidate];
    //remove border
    //有个问题，会影响界面上原本有border的view，不过重新load后会恢复，暂时不管
    self.borderWidth = 0;
    [self updateBorderOfViewHierarchy];
    
    self.showingBusinessBorder = !self.showingBusinessBorder;
    self.borderWidth = 0;
    [self updateBorderOfViewHierarchy];
    self.showingBusinessBorder = !self.showingBusinessBorder;
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
    //do not draw class name imageview's border
    if (view.tag == kClassNameImageViewTag) {
        if (self.borderWidth == 0) {
            //remove class name imageview
            [view removeFromSuperview];
        }
        return;
    }
    
    if (self.showingBusinessBorder) {
        //draw business view's class name
        const char* clzname = object_getClassName(view);
        if (vz_isTrackingObject(clzname))
            [self drawClassName:clzname onView:view];
        
        //对iCoupon无用对其他有用
        //draw business view controller's class name
        if ([view.nextResponder isKindOfClass:[UIViewController class]]) {
            clzname = object_getClassName(view.nextResponder);
            if (vz_isTrackingObject(clzname))
                [self drawClassName:clzname onView:view];
        }
    } else {//all border
        view.layer.borderWidth = self.borderWidth;
        view.layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    [view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [self drawBorderOfViewHierarchy:subview];
    }];
}

- (void)drawClassName:(const char*)clzname onView:(UIView *)view {
    view.layer.borderWidth = self.borderWidth;
    view.layer.borderColor = [UIColor greenColor].CGColor;
    
    BOOL flag = (view.subviews.count != 0) && (((UIView *)view.subviews[view.subviews.count - 1]).tag == kClassNameImageViewTag);
    if (!flag) {
        NSDictionary* stringAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:10], NSForegroundColorAttributeName : [UIColor greenColor]};
        NSString *className = [[NSString alloc] initWithUTF8String:clzname];
        //remove class prefix
        className = [className substringFromIndex:vz_tracking_classPrefix.length];
        //compute text size
        CGSize temp = CGSizeMake(200, 30);
        CGSize textSize = [className boundingRectWithSize:temp options:NSStringDrawingUsesFontLeading attributes:stringAttrs context:NULL].size;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(textSize.width + kClassNamePadding * 2, textSize.height + kClassNamePadding * 2), NO, 2.0);
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:className attributes:stringAttrs];
        [attrStr drawAtPoint:CGPointMake(kClassNamePadding, kClassNamePadding)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = kClassNameImageViewTag;
        imageView.backgroundColor = [UIColor blackColor];
        imageView.alpha = 0.5;
        [view addSubview:imageView];
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

@end
