//
//  VZNetworkInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZNetworkInspector.h"
#import "NSObject+VZInspector.h"
#import "VZLogInspector.h"


NSString* const kVZNetworkInspectorRequestNotification = @"VZNetworkInspectorRequestNotification";

@interface VZNetworkInspector()

@property(nonatomic,assign) NSInteger networkCount;

@end

@implementation VZNetworkInspector

+ (instancetype)sharedInstance
{
    static VZNetworkInspector* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [VZNetworkInspector new];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRequestReceived:) name:kVZNetworkInspectorRequestNotification object:nil];
 
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onRequestReceived:(NSNotification* )notify
{
    self.totalNetworkCount ++ ;
    self.networkCount ++;
    
    if (self.samplePoints == nil)
        self.samplePoints = [NSMutableArray new];
    
    [self.samplePoints addObject:@(self.networkCount)];
    [self.samplePoints addObject:@(self.networkCount)];
    
    self.networkCount --;
    [self.samplePoints addObject:@(self.networkCount)];
    [self.samplePoints addObject:@(self.networkCount)];
    
    
    NSNumber*  len = notify.userInfo[@"data-len"];
    self.totalResponseBytes += len.longValue;
}

- (void)onRequestFinished:(NSNotification* )notify
{
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - for debugger use

- (void)vz_heartBeat
{
    
    if (self.samplePoints == nil)
        self.samplePoints = [NSMutableArray new];
    
    // NSLog(@"request:%d",self.networkCount);
    
    [self.samplePoints addObject:@(self.networkCount)];
    
    //keep last 50 points
    if ( [self.samplePoints count] > 50 )
    {
        NSRange range;
        range.location = 0;
        range.length = [self.samplePoints count] - 50;
        [self.samplePoints removeObjectsInRange:range];
    }
    
}




@end
