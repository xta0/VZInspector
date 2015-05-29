//
//  VZInspectorTimer.m
//  VZInspector
//
//  Created by moxin on 15/4/20.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZInspectorTimer.h"
#import "VZMemoryInspector.h"
#import "VZNetworkInspector.h"
#import "NSObject+VZInspector.h"


NSString const*  kVZTimerReadCallbackString  = @"kVZTimerReadCallbackString";
NSString const*  kVZTimerWriteCallbackString = @"kVZTimerWriteCallbackString";
NSString const*  kVZTimerStartCallbackString = @"kVZTimerStartCallbackString";
NSString const*  kVZTimerStopCallbackString  = @"kVZTimerStopCallbackString";

@interface NSTimer(VZInspector)
+(NSTimer* )scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void(^)())block userInfo:(id)userInfo repeats:(BOOL)repeat;
@end

@implementation NSTimer(VZInspector)

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

@interface VZInspectorTimer()

@property(nonatomic,strong)NSTimer* readTimer;
@property(nonatomic,strong)NSTimer* writeTimer;

@end

@implementation VZInspectorTimer
{

}

+ (instancetype)sharedInstance
{
    static VZInspectorTimer* instance =  nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [VZInspectorTimer new];
    });
    return instance;
}


- (void)startTimer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString* const)kVZTimerStartCallbackString object:nil];
    
    __weak typeof(self) weakSelf = self;
    [VZInspectorTimer sharedInstance].readTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 block:^{
        
        //timer
        [weakSelf  handleRead];
        
    } userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:[VZInspectorTimer sharedInstance].readTimer  forMode:NSRunLoopCommonModes];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [VZInspectorTimer sharedInstance].writeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 block:^{
            
            //timer
            [weakSelf  handleWrite];
            
        } userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:[VZInspectorTimer sharedInstance].writeTimer forMode:NSRunLoopCommonModes];
        
    });
}

- (void)stopTimer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString* const)kVZTimerStopCallbackString object:nil];
    
    [[VZInspectorTimer sharedInstance].readTimer invalidate];
    [[VZInspectorTimer sharedInstance].writeTimer invalidate];
    [VZInspectorTimer sharedInstance].readTimer  = nil;
    [VZInspectorTimer sharedInstance].writeTimer = nil;
}

- (void)handleRead
{
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString* const)kVZTimerReadCallbackString object:nil];
    
    if (self.readCallback) {
        self.readCallback();
    }
}

- (void)handleWrite
{
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString* const)kVZTimerWriteCallbackString object:nil];
    
    if (self.writeCallback) {
        self.writeCallback();
    }
}

@end
