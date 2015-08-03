//
//  VZImageInspector.m
//  VZInspector
//
//  Created by John Wong on 7/31/15.
//  Copyright (c) 2015 VizLabe. All rights reserved.
//

#import "VZImageInspector.h"
#import <UIKit/UIKit.h>
#import <stack>

inline CGSize operator+(const CGSize &s1, const CGSize &s2)
{
    return { s1.width + s2.width, s1.height + s2.height };
}

inline CGSize operator-(const CGSize &s1, const CGSize &s2)
{
    return { s1.width - s2.width, s1.height - s2.height };
}

inline BOOL operator==(const CGSize &s1, const CGSize &s2)
{
    return CGSizeEqualToSize(s1, s2);
}

inline BOOL operator!=(const CGSize &s1, const CGSize &s2)
{
    return !CGSizeEqualToSize(s1, s2);
}

@interface VZTextLayer : CATextLayer

@property (nonatomic, assign) CGColorRef originBorderColor;
@property (nonatomic, assign) CGFloat originBorderWidth;
@property (nonatomic, assign) UIViewContentMode originContentMode;

+ (VZTextLayer *)textLayerWithImageView:(UIImageView *)imageView;

@end

@implementation VZTextLayer

+ (VZTextLayer *)textLayerWithImageView:(UIImageView *)imageView {

    CGSize imageSize = imageView.image.size;
    CGSize frameSize = imageView.frame.size;
    NSString *text = [NSString stringWithFormat:@"%@%@\n%@%@", @(imageView.image.scale), NSStringFromCGSize(imageSize), @([UIScreen mainScreen].scale), NSStringFromCGSize(frameSize)];
            
    VZTextLayer *label = [[VZTextLayer alloc] init];
    label.originBorderColor = imageView.layer.borderColor;
    label.originBorderWidth = imageView.layer.borderWidth;
    label.originContentMode = imageView.contentMode;
    
    UIFont *font = [UIFont systemFontOfSize:13.0];
    label.fontSize = 13;
    label.font = CGFontCreateWithFontName((CFStringRef)font.fontName);
    label.string = text;
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = imageSize;
    label.frame = frame;
    label.foregroundColor = [UIColor whiteColor].CGColor;
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    return label;
}

@end

@interface VZImageInspector ()

@property (nonatomic, assign) BOOL on;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation VZImageInspector

+ (instancetype)sharedInstance {
    static VZImageInspector *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)inspect {
    _on = !_on;
    if (_on) {
        [self updateView];
        [self startTimer];
    } else {
        [self stopTimer];
        [self updateView];
    }
}

- (void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateView) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

+ (UIView *)topView {
    
    UIViewController *currentVC = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        currentVC = nextResponder;
    else
        currentVC = window.rootViewController;
    return currentVC.view;
}

- (void)updateView {
    std::stack<UIView *> stack;
    stack.push([self.class topView]);
    BOOL isOn = _on;
    while (!stack.empty()) {
        UIView *view = stack.top();
        stack.pop();
        if ([view isKindOfClass:[UIImageView class]]) {
            [self.class markImageView:(UIImageView *)view isOn:isOn];
        }
        for (UIView *subView in view.subviews) {
            stack.push(subView);
        }
    }
}

+ (void)markImageView:(UIImageView *)imageView isOn:(BOOL)isOn{
    
    VZTextLayer *textLayer = [self textLayerInLayer:imageView.layer];
    CGSize imageSize = imageView.image ? imageView.image.size : CGSizeZero;
    CGSize frameSize = imageView.frame.size;
    if (isOn && frameSize != imageSize && imageSize != CGSizeZero && frameSize != CGSizeZero) {
        if (!textLayer) {
            textLayer = [VZTextLayer textLayerWithImageView:imageView];
            [imageView.layer addSublayer:textLayer];
            imageView.layer.borderColor = [UIColor greenColor].CGColor;
            imageView.layer.borderWidth = 1;
            imageView.contentMode = UIViewContentModeTopLeft;
        }
    } else {
        if (textLayer) {
            imageView.layer.borderWidth = textLayer.originBorderWidth;
            imageView.layer.borderColor = textLayer.originBorderColor;
            imageView.contentMode = textLayer.originContentMode;
            [textLayer removeFromSuperlayer];
        }
    }
}

+ (VZTextLayer *)textLayerInLayer:(CALayer *)layer {
    for (CALayer *subLayer in layer.sublayers) {
        if ([subLayer isKindOfClass:[VZTextLayer class]]) {
            return (VZTextLayer *)subLayer;
        }
    }
    return nil;
}

@end
