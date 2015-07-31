//
//  VZLogInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-12-16.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZLogInspector.h"
#import <asl.h>
# include <stdio.h>
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

    asl_object_t query = asl_new(ASL_TYPE_QUERY);
    char pidStr[100];
    sprintf(pidStr,"%d",[[NSProcessInfo processInfo] processIdentifier]);
    asl_set_query(query, ASL_KEY_PID, pidStr, ASL_QUERY_OP_EQUAL);
    
    //this is too slow!
    aslresponse response = asl_search(NULL, query);
    NSUInteger numberOfLogs = [VZLogInspector sharedInstance].numberOfLogs;
    NSMutableArray *logMessages = [NSMutableArray arrayWithCapacity:numberOfLogs];
 
    for (int i=0; i<numberOfLogs; i++) {
        
        size_t count = asl_count(response);
        
        size_t index = count - numberOfLogs - 1 + i;
        
        aslmsg msg = asl_get_index(response, index);
   
        if (msg != NULL) {
            
            VZLogInspectorEntity* entity = [VZLogInspectorEntity messageFromASLMessage:msg];
            [logMessages insertObject:entity atIndex:0];
        }
        else
            break;
    }

    asl_release(response);
    [VZLogInspector sharedInstance].logMessages = logMessages;
    
    return logMessages;
}



+ (void)setNumberOfLogs:(NSUInteger)num
{
    [VZLogInspector sharedInstance].numberOfLogs = num;
}

+ (NSAttributedString* )logsString
{
    NSArray* logs = [self logs];
    
    NSMutableAttributedString* attr = [NSMutableAttributedString new];
    UIFont* font = [UIFont fontWithName:@"Courier-Bold" size:12];
    
    for (VZLogInspectorEntity* entity in logs) {
        
        NSString* logStr = [NSString stringWithFormat:@"%@ > %@ \n\n",[VZInspectorUtility stringFormatFromDate:entity.date],entity.messageText];
        NSMutableAttributedString* logAttr = [[NSMutableAttributedString alloc]initWithString:logStr];
        [logAttr addAttribute:NSForegroundColorAttributeName value:[UIColor cyanColor] range:NSMakeRange(0, [VZInspectorUtility stringFormatFromDate:entity.date].length+2)];
        [logAttr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange([VZInspectorUtility stringFormatFromDate:entity.date].length+3, logStr.length-[VZInspectorUtility stringFormatFromDate:entity.date].length-3)];
        [logAttr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, logStr.length-1)];

        [attr appendAttributedString:logAttr];
    }

    return attr;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        _cache = [NSCache new];
        _cache.totalCostLimit = 25 * 1024 * 1024;
        _numberOfLogs = kVZDefaultNumberOfLogs;
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