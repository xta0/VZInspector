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
#import "VZNetworkObserver.h"


NSString* const kVZNetworkInspectorRequestNotification = @"VZNetworkInspectorRequestNotification";
NSString* const kVZNetworkInspectorRequestFinishedNotification = @"VZNetworkInspectorRequestFinishedNotification";


@interface VZNetworkInspector()

@property(nonatomic,assign) NSInteger networkCount;

@end

@implementation VZNetworkInspector {
    NSMutableArray *_titleFilters;
}

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
        _titleFilters = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRequestReceived:) name:kVZNetworkInspectorRequestNotification object:nil];
 
        _requestDecoders = [NSMutableArray array];
        _responseDecoders = [NSMutableArray array];
        
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

- (void)addTransactionTitleFilter:(TransactionTitleFilter)filter
{
    [_titleFilters addObject:filter];
}

- (NSArray *)transactionTitleFilters
{
    return [_titleFilters copy];
}

+ (void)setIgnoreDelegateClasses:(NSSet *)classes
{
    [VZNetworkObserver setIgnoreDelegateClasses:classes];
}

- (void)addRequestDecoder:(VZNetworkDecoder)decoder
{
    if (decoder) {
        [_requestDecoders addObject:decoder];
    }
}

- (void)addResponseDecoder:(VZNetworkDecoder)decoder
{
    if (decoder) {
        [_responseDecoders addObject:decoder];
    }
}

- (NSString *)decodeRequestData:(NSData *)data withTransaction:(VZNetworkTransaction *)transaction
{
    for (VZNetworkDecoder decoder in [VZNetworkInspector sharedInstance].requestDecoders) {
        NSString *result = decoder(transaction, data);
        if (result.length > 0) {
            return result;
        }
    }
    return nil;
}

- (NSString *)decodeResponseData:(NSData *)data withTransaction:(VZNetworkTransaction *)transaction
{
    for (VZNetworkDecoder decoder in [VZNetworkInspector sharedInstance].responseDecoders) {
        NSString *result = decoder(transaction, data);
        if (result.length > 0) {
            return result;
        }
    }
    return nil;
}

@end
