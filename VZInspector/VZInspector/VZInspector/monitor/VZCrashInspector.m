//
//  VZCrashInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZCrashInspector.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

@implementation VZCrashInspector

{
    BOOL          _isInstalled;
    NSString*     _crashLogPath;
    NSMutableArray* _plist;
}

+ (instancetype)sharedInstance
{
    static VZCrashInspector* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [VZCrashInspector new];
    });
    return instance;
}

const int maxCrashLogNum  = 20;

//handle exception

void HandleException(NSException *exception)
{
    [[VZCrashInspector sharedInstance]saveException:exception];
    abort();
}

void SignalHandler(int signal)
{

}

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    
    //skip 4, max is 10
    for (i = 4;i < 10;i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

- (id)init
{
    self = [super init];
    if ( self )
    {
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString* sandBoxPath  = [paths objectAtIndex:0];
        
    
        _crashLogPath = [sandBoxPath stringByAppendingPathComponent:@"VZCrashLog"];
        
        if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:_crashLogPath] )
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:_crashLogPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        
        //creat plist
        if (YES == [[NSFileManager defaultManager] fileExistsAtPath:[_crashLogPath stringByAppendingPathComponent:@"crashLog.plist"]])
        {
            _plist = [[NSMutableArray arrayWithContentsOfFile:[_crashLogPath stringByAppendingPathComponent:@"crashLog.plist"]] mutableCopy];
        }
        else
            _plist = [NSMutableArray new];
    }
    return self;
}

- (NSDictionary* )crashForKey:(NSString *)key
{
    NSString* filePath = [[_crashLogPath stringByAppendingPathComponent:key] stringByAppendingString:@".plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    return dict;
}

- (NSArray* )crashPlist
{
    return [_plist copy];
}

- (NSArray* )crashLogs
{
    NSMutableArray* ret = [NSMutableArray new];
    for (NSString* key in _plist) {
        
        NSString* filePath = [_crashLogPath stringByAppendingPathComponent:key];
        NSString* path = [filePath stringByAppendingString:@".plist"];
        NSDictionary* log = [NSDictionary dictionaryWithContentsOfFile:path];
        [ret addObject:log];
    }
    return [ret copy];
}


- (NSDictionary* )crashReport
{
    for (NSString* key in _plist) {
        
        NSString* filePath = [_crashLogPath stringByAppendingPathComponent:key];
        
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        return dict;
    }
    return nil;
    
}

- (void)install
{
    if (_isInstalled) {
        return;
    }
    //注册回调函数
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}

- (void)dealloc
{
    signal( SIGABRT,	SIG_DFL );
    signal( SIGBUS,		SIG_DFL );
    signal( SIGFPE,		SIG_DFL );
    signal( SIGILL,		SIG_DFL );
    signal( SIGPIPE,	SIG_DFL );
    signal( SIGSEGV,	SIG_DFL );
}

- (void)saveException:(NSException*)exception
{
    NSMutableDictionary * detail = [NSMutableDictionary dictionary];
    if ( exception.name )
    {
        [detail setObject:exception.name forKey:@"name"];
    }
    if ( exception.reason )
    {
        [detail setObject:exception.reason forKey:@"reason"];
    }
    if ( exception.userInfo )
    {
        [detail setObject:exception.userInfo forKey:@"userInfo"];
    }
    if ( exception.callStackSymbols )
    {
        [detail setObject:exception.callStackSymbols forKey:@"callStack"];
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@"exception" forKey:@"type"];
    [dict setObject:detail forKey:@"info"];
    
    [self saveToFile:dict];
    
}

- (void)saveSignal:(int) signal
{
    //get back trace stack
    NSArray* backTrace = [VZCrashInspector backtrace];
    
    NSMutableDictionary * detail = [NSMutableDictionary dictionary];
    [detail setObject:backTrace forKey:@"callStack"];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@"signal" forKey:@"type"];
    [dict setObject:detail forKey:@"info"];
    
    [self saveToFile:dict];
    
}

- (void)saveToFile:(NSMutableDictionary*)dict
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString* dateString = [formatter stringFromDate:[NSDate date]];
    
    //add date
    [dict setObject:dateString forKey:@"date"];
    
    //save path
    NSString* savePath = [[_crashLogPath stringByAppendingPathComponent:dateString] stringByAppendingString:@".plist"];
    
    //save to disk
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL succeed = [ dict writeToFile:savePath atomically:YES];
        if ( NO == succeed )
        {
            NSLog(@"【save crash report failed!】");
        }
        else
            NSLog(@"【save crash report succeed!】");
        
        [_plist addObject:dateString];
        [_plist writeToFile:[_crashLogPath stringByAppendingPathComponent:@"crashLog.plist"] atomically:YES];
        
        if (_plist.count > maxCrashLogNum)
        {
            [[NSFileManager defaultManager] removeItemAtPath:[_crashLogPath stringByAppendingPathComponent:_plist[0]] error:nil];
            [_plist removeObject:0];
            [_plist writeToFile:[_crashLogPath stringByAppendingPathComponent:@"crashLog.plist"] atomically:YES];
        }
        
    });
}

@end
