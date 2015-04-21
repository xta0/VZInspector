//
//  VZInspectorTimer.m
//  VZInspector
//
//  Created by moxin on 15/4/20.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import "VZInspectorTimer.h"
#import "VZMemoryInspector.h"
#import "VZNetworkInspector.h"
#import "NSObject+VZInspector.h"

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
    NSTimer* readTimer  = [VZInspectorTimer sharedInstance].readTimer;
    __block NSTimer* writeTimer = [VZInspectorTimer sharedInstance].writeTimer;
    
    [readTimer invalidate];
    [writeTimer invalidate];
    
    readTimer = nil;
     writeTimer = nil;

    __weak typeof(self) weakSelf = self;
    readTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 block:^{
        
        //timer
        [weakSelf  handleRead];
        
    } userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:readTimer  forMode:NSRunLoopCommonModes];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        writeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 block:^{
            
            //timer
            [weakSelf  handeWrite];
            
        } userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:writeTimer forMode:NSRunLoopCommonModes];
        
    });
}

- (void)stopTimer
{
    [VZInspectorTimer sharedInstance].readTimer  = nil;
    [VZInspectorTimer sharedInstance].writeTimer = nil;

}

- (void)handleRead
{
    if (self.readCallback) {
        self.readCallback();
    }
}

- (void)handeWrite
{
    if (self.writeCallback) {
        self.writeCallback();
    }
}

@end
