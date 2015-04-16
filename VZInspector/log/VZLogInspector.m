//
//  VZLogInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-12-16.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZLogInspector.h"
#import <asl.h>
#import "VZInspectorUtility.h"


@interface VZLogInspectorEntity()

+ (instancetype)messageFromASLMessage:(aslmsg)aslMessage;

@end

@interface VZLogInspector()

@property(nonatomic,strong)  NSCache* cache;
@property(nonatomic,assign)  NSUInteger numberOfLogs;
@property(nonatomic,strong)  NSMutableArray* logMessages;
@property(nonatomic,strong)  NSString* logString;

@end

extern aslmsg asl_next(asl_object_t obj) __attribute__((weak_import));
extern void asl_release(asl_object_t obj) __attribute__((weak_import));


@implementation VZLogInspector
{
   
}

+ (instancetype) sharedInstance
{
    static VZLogInspector* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [VZLogInspector new];
    });
    return instance;
}


+ (NSArray* )logs
{
   // return [VZLogInspector sharedInstance].cache ob
    
    asl_object_t query = asl_new(ASL_TYPE_QUERY);
    
    // Filter for messages from the current process. Note that this appears to happen by default on device, but is required in the simulator.
    NSString *pidString = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
    asl_set_query(query, ASL_KEY_PID, [pidString UTF8String], ASL_QUERY_OP_EQUAL);
    
    aslresponse response = asl_search(NULL, query);
    aslmsg aslMessage = NULL;
    
    NSMutableArray *logMessages = [NSMutableArray array];
    
    if (&asl_next != NULL && &asl_release != NULL)
    {
        while ((aslMessage = asl_next(response)))
        {
            VZLogInspectorEntity* entity = [VZLogInspectorEntity messageFromASLMessage:aslMessage];
            [logMessages insertObject:entity atIndex:0];
            //[[VZLogInspector sharedInstance].cache setObject:entity forKey:@(entity.messageID)];
        }
        asl_release(response);
    }
    else
    {
        // Mute incorrect deprecated warnings. We'll need the "deprecated" functions on iOS 7, where their replacements don't yet exist.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        while ((aslMessage = aslresponse_next(response)))
        {
            VZLogInspectorEntity* entity = [VZLogInspectorEntity messageFromASLMessage:aslMessage];
            [logMessages insertObject:entity atIndex:0];
            //[[VZLogInspector sharedInstance].cache setObject:entity forKey:@(entity.messageID)];
        }
        aslresponse_free(response);
#pragma clang diagnostic pop
    }
    
    NSUInteger numberOfLogs = [VZLogInspector sharedInstance].numberOfLogs;
    if ( numberOfLogs > 0 && logMessages.count > numberOfLogs) {
        
        NSUInteger count = logMessages.count - numberOfLogs;
        //干掉后面的
        [logMessages removeObjectsInRange:NSMakeRange(numberOfLogs, count)];
    }
    
    [VZLogInspector sharedInstance].logMessages = logMessages;
    
    return logMessages;
}



+ (void)setNumberOfLogs:(NSUInteger)num
{
    [VZLogInspector sharedInstance].numberOfLogs = num;
}

+ (NSString* )logsString
{
    NSArray* logs = [self logs];
    
    NSString* str = @"";
    for (VZLogInspectorEntity* entity in logs) {
        
        NSString* date = [VZInspectorUtility stringFormatFromDate:entity.date];
        
        NSString* log = [NSString stringWithFormat:@"> %@ : %@",date,entity.messageText];
       // NSString* log = [[@"> " stringByAppendingString:date] stringByAppendingString:entity.messageText];
    
        str = [[str stringByAppendingString:log] stringByAppendingString:@"\n\n"];
    }
    return str;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        _cache = [NSCache new];
        _cache.totalCostLimit = 25 * 1024 * 1024;
    }
    return self;
}

@end


@implementation VZLogInspectorEntity

+(instancetype)messageFromASLMessage:(aslmsg)aslMessage
{
    VZLogInspectorEntity *logMessage = [[VZLogInspectorEntity alloc] init];
    
    const char *timestamp = asl_get(aslMessage, ASL_KEY_TIME);
    if (timestamp) {
        NSTimeInterval timeInterval = [@(timestamp) integerValue];
        const char *nanoseconds = asl_get(aslMessage, ASL_KEY_TIME_NSEC);
        if (nanoseconds) {
            timeInterval += [@(nanoseconds) doubleValue] / NSEC_PER_SEC;
        }
        logMessage.date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }
    
    const char *sender = asl_get(aslMessage, ASL_KEY_SENDER);
    if (sender) {
        logMessage.sender = @(sender);
    }
    
    const char *messageText = asl_get(aslMessage, ASL_KEY_MSG);
    if (messageText) {
        logMessage.messageText = @(messageText);
        
    }
    
    const char *messageID = asl_get(aslMessage, ASL_KEY_MSG_ID);
    if (messageID) {
        logMessage.messageID = [@(messageID) longLongValue];

    }
    
    return logMessage;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[VZLogInspectorEntity class]] && self.messageID == [object messageID];
}

- (NSUInteger)hash
{
    return (NSUInteger)self.messageID;
}

@end