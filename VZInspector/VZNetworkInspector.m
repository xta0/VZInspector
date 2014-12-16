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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRequestReceived:) name:[VZLogInspector requestLogIdentifier] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRequestFinished:) name:[VZLogInspector responseLogIdentifier]object:nil];
        
        
    }
    return self;
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
    
    
    id message = notify.userInfo[@"url"];
    if ([message isEqual:[NSNull null]]) {
        return;
    }
    else
    {
        NSString* urlString = [NSString stringWithFormat:@"%@",message];
        NSData* data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
        self.totalResponseBytes += data.length;
    }
    
}

- (void)onRequestFinished:(NSNotification* )notify
{
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - for debugger use

- (void)heartBeat
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
