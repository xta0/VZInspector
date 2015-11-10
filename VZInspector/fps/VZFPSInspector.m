//
//  VZFPSInspector.m
//  VZInspector
//
//  Created by moxin on 15/11/4.
//  Copyright © 2015年 VizLab. All rights reserved.
//

#include <execinfo.h>
#include <QuartzCore/QuartzCore.h>
#import "VZFPSInspector.h"


static void vz_callstack_signal_handler(int signr, siginfo_t *info, void *secret) {
 
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);

}


@implementation VZFPSInspector
{
    CADisplayLink* _displayLink;
    NSThread* _trackerThread;
}


- (void)start
{
    [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    _trackerThread = [[NSThread alloc] initWithTarget:[self class] selector:@selector(trackerLoop) object:nil];
    _trackerThread.threadPriority = 1.0;
    [_trackerThread start];
}


- (void)sendSignal
{
    struct sigaction sa;
    sigfillset(&sa.sa_mask);
    sa.sa_flags = SA_SIGINFO;
    sa.sa_sigaction = vz_callstack_signal_handler;
    sigaction(SIGPROF, &sa, NULL);

}

- (void)update
{
    
}

- (void)trackerLoop
{
    @autoreleasepool {
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
        
    }
}

@end
