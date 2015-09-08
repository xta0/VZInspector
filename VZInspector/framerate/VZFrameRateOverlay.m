//
//  VZFrameRateOverlay.m
//  VZInspector
//
//  Created by lingwan on 15/9/8.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZFrameRateOverlay.h"
#import "VZInspector.h"
#import "VZInspectorResource.h"
#import "VZInspectorOverlay.h"

@interface VZFrameRateOverlay ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UILabel *frameRateLabel;
@end

@implementation VZFrameRateOverlay

+ (instancetype)sharedInstance {
    static VZFrameRateOverlay* instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        int x = [UIScreen mainScreen].bounds.size.width > 320 ? 250 :180 ;
        instance = [[VZFrameRateOverlay alloc] initWithFrame:CGRectMake(x + 15, 0, 60, 20)];
    });
    
    return instance;
}

+ (void)start {
    [VZInspectorOverlay sharedInstance].hidden = YES;
    
    VZFrameRateOverlay* o = [self sharedInstance];
    o.tag = 100;
    o.windowLevel = UIWindowLevelStatusBar+1;
    o.hidden = NO;
    
    o.displayLink.paused = NO;
}

+ (void)stop {
    VZFrameRateOverlay* o = [self sharedInstance];
    o.hidden = YES;
    
    [VZInspectorOverlay sharedInstance].hidden = NO;
    
    o.displayLink.paused = YES;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
        
        _frameRateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _frameRateLabel.font = [UIFont systemFontOfSize:12.f];
        _frameRateLabel.textColor = [UIColor orangeColor];
        _frameRateLabel.userInteractionEnabled = true;
        [_frameRateLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSelfClicked:)]];
        [self addSubview:_frameRateLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationDidBecomeActiveNotification)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillResignActiveNotification)
                                                     name: UIApplicationWillResignActiveNotification
                                                   object: nil];
    }
    
    return self;
}

- (void)applicationDidBecomeActiveNotification {
    if (!self.hidden) {
        [_displayLink setPaused:NO];
    }
}

- (void)applicationWillResignActiveNotification {
    if (!self.hidden) {
        [_displayLink setPaused:YES];
    }
}

- (void)displayLinkTick:(CADisplayLink *)displayLink {
    CGFloat frameRate = 1/displayLink.duration < 60 ? 1/displayLink.duration : 60;
    _frameRateLabel.text = [NSString stringWithFormat:@"%.ffps", frameRate];
}

- (void)onSelfClicked:(UILabel *)sender {
    if([VZInspector isShow])
        [VZInspector hide];
    else
        [VZInspector show];
}

- (void)becomeKeyWindow {
    //fix keywindow problem:
    //UIActionSheet在close后回重置keywindow，防止自己被设成keywindow
    [[[UIApplication sharedApplication].delegate window] makeKeyWindow];
}

@end
