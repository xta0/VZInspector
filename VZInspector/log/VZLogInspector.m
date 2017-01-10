//
//  VZLogInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-12-16.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZLogInspector.h"
#import "VZInspectorUtility.h"
#include <asl.h>
#include <notify.h>
#include <notify_keys.h>
#include <sys/time.h>
#include <stdio.h>

static BOOL _cancel = YES;
const char* const kVZInspecotrASLKeyDDLog = "VZLog";

const char* const kVZInspecotrASLDDLogValue = "1";

typedef NS_OPTIONS(NSUInteger, VZLogFlag){
    VZLogFlagError      = (1 << 0),
    
    VZLogFlagWarning    = (1 << 1),
    
    VZLogFlagInfo       = (1 << 2),
    
    VZLogFlagDebug      = (1 << 3),

    VZLogFlagVerbose    = (1 << 4)
};



@interface VZLogInspectorEntity()

+(instancetype)messageFromASLMessage:(aslmsg)aslMessage;

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
    
    int flag ;
    const char* levelCString = asl_get(aslMessage, ASL_KEY_LEVEL);
    switch (levelCString? atoi(levelCString) : 0) {
            // By default all NSLog's with a ASL_LEVEL_WARNING level
        case ASL_LEVEL_EMERG    :
        case ASL_LEVEL_ALERT    :
        case ASL_LEVEL_CRIT     : flag = VZLogFlagError;    break;
        case ASL_LEVEL_ERR      : flag = VZLogFlagWarning;  break;
        case ASL_LEVEL_WARNING  : flag = VZLogFlagInfo;     break;
        case ASL_LEVEL_NOTICE   : flag = VZLogFlagDebug;    break;
        case ASL_LEVEL_INFO     :
        case ASL_LEVEL_DEBUG    :
        default                 : flag = VZLogFlagVerbose;  break;
    }
    
    logMessage.level = flag;
    
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


//from : https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Classes/DDASLLogCapture.m
static aslmsg (*dd_asl_next)(aslresponse obj);
static void (*dd_asl_release)(aslresponse obj);
+ (void)initialize
{
#if (defined(DDASL_IOS_PIVOT_VERSION) && __IPHONE_OS_VERSION_MAX_ALLOWED >= DDASL_IOS_PIVOT_VERSION) || (defined(DDASL_OSX_PIVOT_VERSION) && __MAC_OS_X_VERSION_MAX_ALLOWED >= DDASL_OSX_PIVOT_VERSION)
#if __IPHONE_OS_VERSION_MIN_REQUIRED < DDASL_IOS_PIVOT_VERSION || __MAC_OS_X_VERSION_MIN_REQUIRED < DDASL_OSX_PIVOT_VERSION
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    // Building on falsely advertised SDK, targeting deprecated API
    dd_asl_next    = &aslresponse_next;
    dd_asl_release = &aslresponse_free;
#pragma GCC diagnostic pop
#else
    // Building on lastest, correct SDK, targeting latest API
    dd_asl_next    = &asl_next;
    dd_asl_release = &asl_release;
#endif
#else
    // Building on old SDKs, targeting deprecated API
    dd_asl_next    = &aslresponse_next;
    dd_asl_release = &aslresponse_free;
#endif
}

+ (NSArray* )logs
{

    NSArray* ret = @[];
    
    asl_object_t query = asl_new(ASL_TYPE_QUERY);
    char pidStr[100];
    sprintf(pidStr,"%d",[[NSProcessInfo processInfo] processIdentifier]);
    asl_set_query(query, ASL_KEY_PID, pidStr, ASL_QUERY_OP_EQUAL);
    
    //this is too slow!
    aslresponse response = asl_search(NULL, query);
    aslmsg msg;
    if (response != NULL) {
        
        NSUInteger numberOfLogs = [VZLogInspector sharedInstance].numberOfLogs;
        NSMutableArray *logMessages = [NSMutableArray arrayWithCapacity:numberOfLogs];
        
        while ((msg = dd_asl_next(response)))
        {
            VZLogInspectorEntity* entity = [VZLogInspectorEntity messageFromASLMessage:msg];
            [logMessages insertObject:entity atIndex:0];
        }
        [VZLogInspector sharedInstance].logMessages = logMessages;
        ret = [logMessages copy];

    }
    else{
        VZLogInspectorEntity* entity = [VZLogInspectorEntity new];
        entity.date = [NSDate date];
        entity.sender = @"VZInspector";
        entity.messageText = @"[Error]-->Can not read device log!";
        entity.messageID = -1;
        ret = @[entity];
    }
    
    if (query != NULL) {
        asl_free(query);
    }
    
    if (response != NULL) {
        dd_asl_release(response);
    }
 
    return ret;
}



+ (void)setNumberOfLogs:(NSUInteger)num
{
    [VZLogInspector sharedInstance].numberOfLogs = num;
}

+ (NSAttributedString* )logsString:(NSString *)searchKey
{
    NSArray* logs = [self logs];
    
    NSMutableAttributedString* attr = [NSMutableAttributedString new];
    
    for (VZLogInspectorEntity* entity in logs) {
        NSMutableAttributedString* logAttr = [VZLogInspector formatLog:entity searchkey:searchKey];
        if (logAttr) {
            [attr appendAttributedString:logAttr];
        }
    }

    return attr;
}

+(NSAttributedString *)formatLog:(VZLogInspectorEntity *)entity searchkey:(NSString *)searchKey{
    NSUInteger index = NSNotFound;
    if (entity.messageText.length==0) {
        return nil;
    }
    if (searchKey.length>0) {
        index = [entity.messageText rangeOfString:searchKey options:NSCaseInsensitiveSearch].location;
        if (index == NSNotFound) {
            return  nil;
        }
    }
    
    UIFont* font = [UIFont fontWithName:@"Courier-Bold" size:12];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@",[VZInspectorUtility stringFormatFromDate:entity.date]];
    NSString* logStr = [NSString stringWithFormat:@"%@ > %@ \n\n",dateStr,entity.messageText];
    NSMutableAttributedString* logAttr = [[NSMutableAttributedString alloc]initWithString:logStr];
    [logAttr addAttribute:NSForegroundColorAttributeName value:[UIColor cyanColor] range:NSMakeRange(0, dateStr.length+2)];
    
    if (index!=NSNotFound) {
        NSUInteger newIndex = dateStr.length + 3 +index;
        
        [logAttr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(dateStr.length+3,newIndex-dateStr.length-3)];
        [logAttr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(newIndex , searchKey.length)];
        [logAttr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(newIndex+searchKey.length ,logStr.length - newIndex - searchKey.length)];
    }else{
        [logAttr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(dateStr.length+3, logStr.length-dateStr.length-3)];
    }
    
    [logAttr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, logStr.length-1)];
    
    return logAttr;
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

+ (void)captureAslLogs {
    @autoreleasepool
    {
        /*
         We use ASL_KEY_MSG_ID to see each message once, but there's no
         obvious way to get the "next" ID. To bootstrap the process, we'll
         search by timestamp until we've seen a message.
         */
        
        struct timeval timeval = {
            .tv_sec = 0
        };
        gettimeofday(&timeval, NULL);
        unsigned long long startTime = timeval.tv_sec;
        __block unsigned long long lastSeenID = 0;
        
        /*
         syslogd posts kNotifyASLDBUpdate (com.apple.system.logger.message)
         through the notify API when it saves messages to the ASL database.
         There is some coalescing - currently it is sent at most twice per
         second - but there is no documented guarantee about this. In any
         case, there may be multiple messages per notification.
         
         Notify notifications don't carry any payload, so we need to search
         for the messages.
         */
        int notifyToken = 0;  // Can be used to unregister with notify_cancel().
        notify_register_dispatch(kNotifyASLDBUpdate, &notifyToken, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(int token)
                                 {
                                     // At least one message has been posted; build a search query.
                                     @autoreleasepool
                                     {
                                         aslmsg query = asl_new(ASL_TYPE_QUERY);
                                         char stringValue[64];
                                         
                                         if (lastSeenID > 0) {
                                             snprintf(stringValue, sizeof stringValue, "%llu", lastSeenID);
                                             asl_set_query(query, ASL_KEY_MSG_ID, stringValue, ASL_QUERY_OP_GREATER | ASL_QUERY_OP_NUMERIC);
                                         } else {
                                             snprintf(stringValue, sizeof stringValue, "%llu", startTime);
                                             asl_set_query(query, ASL_KEY_TIME, stringValue, ASL_QUERY_OP_GREATER_EQUAL | ASL_QUERY_OP_NUMERIC);
                                         }
                                         
                                         [self configureAslQuery:query];
                                         
                                         // Iterate over new messages.
                                         aslmsg msg;
                                         aslresponse response = asl_search(NULL, query);
                                         
                                         while ((msg = dd_asl_next(response)))
                                         {
                                             [self aslMessageReceived:msg];
                                             
                                             // Keep track of which messages we've seen.
                                             lastSeenID = atoll(asl_get(msg, ASL_KEY_MSG_ID));
                                         }
                                         dd_asl_release(response);
                                         asl_free(query);
                                         
                                         if (_cancel) {
                                             notify_cancel(token);
                                             return;
                                         }
                                         
                                     }
                                 });
    }
}

+ (void)configureAslQuery:(aslmsg)query {
    const char param[] = "7";  // ASL_LEVEL_DEBUG, which is everything. We'll rely on regular DDlog log level to filter
    
    asl_set_query(query, ASL_KEY_LEVEL, param, ASL_QUERY_OP_LESS_EQUAL | ASL_QUERY_OP_NUMERIC);
    
    // Don't retrieve logs from our own DDASLLogger
    asl_set_query(query, kVZInspecotrASLKeyDDLog, kVZInspecotrASLDDLogValue, ASL_QUERY_OP_NOT_EQUAL);
    
#if !TARGET_OS_IPHONE || TARGET_SIMULATOR
    int processId = [[NSProcessInfo processInfo] processIdentifier];
    char pid[16];
    sprintf(pid, "%d", processId);
    asl_set_query(query, ASL_KEY_PID, pid, ASL_QUERY_OP_EQUAL | ASL_QUERY_OP_NUMERIC);
#endif
}

+ (void)aslMessageReceived:(aslmsg)msg {
   
    VZLogInspector *logInspector = [VZLogInspector sharedInstance];
    VZLogInspectorEntity *entity = [VZLogInspectorEntity messageFromASLMessage:msg];
    
    [logInspector.observers enumerateObjectsUsingBlock:^(id<VZLogInspectorDelegate> observer, NSUInteger idx, BOOL * _Nonnull stop) {
        if(observer && [observer respondsToSelector:@selector(logMessage:)]){
            [observer logMessage:entity];
        }
    }];
    
}

+ (void)start {
    // Ignore subsequent calls
    if (!_cancel) {
        return;
    }
    
    _cancel = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self captureAslLogs];
    });
}

+ (void)stop {
    _cancel = YES;
}

- (void)removeObserver:(id<VZLogInspectorDelegate>)observer{
    [self.observers removeObject:observer];
}

- (void)addObserver:(id<VZLogInspectorDelegate>)observer{
    if([observer conformsToProtocol:@protocol(VZLogInspectorDelegate)]){
        [self.observers addObject:observer];
    }
}

- (NSMutableArray *)observers{
    if(!_observers){
        _observers = [[NSMutableArray alloc]init];
    }
    return _observers;
}


@end



//@end
