//
//  VZNetworkRecorder.m
//  VZInspector
//
//  Created by moxin on 15/4/15.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import "VZNetworkRecorder.h"
#import "VZNetworkTransaction.h"


NSString *const kVZNetworkRecorderNewTransactionNotification = @"kVZNetworkRecorderNewTransactionNotification";
NSString *const kVZNetworkRecorderTransactionUpdatedNotification = @"kVZNetworkRecorderTransactionUpdatedNotification";
NSString *const kVZNetworkRecorderUserInfoTransactionKey = @"transaction";
NSString *const kVZNetworkRecorderTransactionsClearedNotification = @"kVZNetworkRecorderTransactionsClearedNotification";
NSString *const kVZNetworkRecorderResponseCacheLimitDefaultsKey = @"com.VZ.responseCacheLimit";

@interface VZNetworkRecorder ()

@property (nonatomic, strong) NSCache *responseCache;
@property (nonatomic, strong) NSMutableArray *orderedTransactions;
@property (nonatomic, strong) NSMutableDictionary *networkTransactionsForRequestIdentifiers;
@property (nonatomic, strong) dispatch_queue_t queue;

@end


@implementation VZNetworkRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.responseCache = [[NSCache alloc] init];
        NSUInteger responseCacheLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:kVZNetworkRecorderResponseCacheLimitDefaultsKey] unsignedIntegerValue];
        if (responseCacheLimit) {
            [self.responseCache setTotalCostLimit:responseCacheLimit];
        } else {
            // Default to 25 MB max. The cache will purge earlier if there is memory pressure.
            [self.responseCache setTotalCostLimit:25 * 1024 * 1024];
        }
        self.orderedTransactions = [NSMutableArray array];
        self.networkTransactionsForRequestIdentifiers = [NSMutableDictionary dictionary];
        
        // Serial queue used because we use mutable objects that are not thread safe
        self.queue = dispatch_queue_create("com.VZ.VZNetworkRecorder", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (instancetype)defaultRecorder
{
    static VZNetworkRecorder *defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [[[self class] alloc] init];
    });
    return defaultRecorder;
}

#pragma mark - Public Data Access

- (NSUInteger)responseCacheByteLimit
{
    return [self.responseCache totalCostLimit];
}

- (void)setResponseCacheByteLimit:(NSUInteger)responseCacheByteLimit
{
    [self.responseCache setTotalCostLimit:responseCacheByteLimit];
    [[NSUserDefaults standardUserDefaults] setObject:@(responseCacheByteLimit) forKey:kVZNetworkRecorderResponseCacheLimitDefaultsKey];
}

- (NSArray *)networkTransactions
{
    __block NSArray *transactions = nil;
    dispatch_sync(self.queue, ^{
        transactions = [self.orderedTransactions copy];
    });
    return transactions;
}

- (NSData *)cachedResponseBodyForTransaction:(VZNetworkTransaction *)transaction
{
    return [self.responseCache objectForKey:transaction.requestID];
}

- (void)clearRecordedActivity
{
    dispatch_async(self.queue, ^{
        [self.responseCache removeAllObjects];
        [self.orderedTransactions removeAllObjects];
        [self.networkTransactionsForRequestIdentifiers removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kVZNetworkRecorderTransactionsClearedNotification object:self];
        });
    });
}

#pragma mark - Network Events

- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID request:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    NSDate *startDate = [NSDate date];
    
    if (redirectResponse) {
        [self recordResponseReceivedWithRequestID:requestID response:redirectResponse];
        [self recordLoadingFinishedWithRequestID:requestID responseBody:nil];
    }
    
    dispatch_async(self.queue, ^{
        VZNetworkTransaction *transaction = [[VZNetworkTransaction alloc] init];
        transaction.requestID = requestID;
        transaction.request = request;
        transaction.startTime = startDate;
        
        [self.orderedTransactions insertObject:transaction atIndex:0];
        [self.networkTransactionsForRequestIdentifiers setObject:transaction forKey:requestID];
        transaction.transactionState = VZNetworkTransactionStateAwaitingResponse;
        
        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response
{
    NSDate *responseDate = [NSDate date];
    
    dispatch_async(self.queue, ^{
        VZNetworkTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        transaction.response = response;
        transaction.transactionState = VZNetworkTransactionStateReceivingData;
        transaction.latency = -[transaction.startTime timeIntervalSinceDate:responseDate];
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength
{
    dispatch_async(self.queue, ^{
        VZNetworkTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        transaction.receivedDataLength += dataLength;
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody
{
    NSDate *finishedDate = [NSDate date];
    
    dispatch_async(self.queue, ^{
        VZNetworkTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = VZNetworkTransactionStateFinished;
        transaction.duration = -[transaction.startTime timeIntervalSinceDate:finishedDate];
        
        BOOL shouldCache = [responseBody length] > 0;
        if (!self.shouldCacheMediaResponses) {
            NSArray *ignoredMIMETypePrefixes = @[ @"audio", @"image", @"video" ];
            for (NSString *ignoredPrefix in ignoredMIMETypePrefixes) {
                shouldCache = shouldCache && ![transaction.response.MIMEType hasPrefix:ignoredPrefix];
            }
        }
        
        if (shouldCache) {
            [self.responseCache setObject:responseBody forKey:requestID cost:[responseBody length]];
        }
        
//        NSString *mimeType = transaction.response.MIMEType;
//        if ([mimeType hasPrefix:@"image/"] && [responseBody length] > 0) {
//            // Thumbnail image previews on a separate background queue
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSInteger maxPixelDimension = [[UIScreen mainScreen] scale] * 32.0;
//                transaction.responseThumbnail = [VZUtility thumbnailedImageWithMaxPixelDimension:maxPixelDimension fromImageData:responseBody];
//                [self postUpdateNotificationForTransaction:transaction];
//            });
//        } else if ([mimeType isEqual:@"application/json"]) {
//            transaction.responseThumbnail = [VZResources jsonIcon];
//        } else if ([mimeType isEqual:@"text/plain"]){
//            transaction.responseThumbnail = [VZResources textPlainIcon];
//        } else if ([mimeType isEqual:@"text/html"]) {
//            transaction.responseThumbnail = [VZResources htmlIcon];
//        } else if ([mimeType isEqual:@"application/x-plist"]) {
//            transaction.responseThumbnail = [VZResources plistIcon];
//        } else if ([mimeType isEqual:@"application/octet-stream"] || [mimeType isEqual:@"application/binary"]) {
//            transaction.responseThumbnail = [VZResources binaryIcon];
//        } else if ([mimeType rangeOfString:@"javascript"].length > 0) {
//            transaction.responseThumbnail = [VZResources jsIcon];
//        } else if ([mimeType rangeOfString:@"xml"].length > 0) {
//            transaction.responseThumbnail = [VZResources xmlIcon];
//        } else if ([mimeType hasPrefix:@"audio"]) {
//            transaction.responseThumbnail = [VZResources audioIcon];
//        } else if ([mimeType hasPrefix:@"video"]) {
//            transaction.responseThumbnail = [VZResources videoIcon];
//        } else if ([mimeType hasPrefix:@"text"]) {
//            transaction.responseThumbnail = [VZResources textIcon];
//        }
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error
{
    dispatch_async(self.queue, ^{
        VZNetworkTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = VZNetworkTransactionStateFailed;
        transaction.duration = -[transaction.startTime timeIntervalSinceNow];
        transaction.error = error;
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID
{
    dispatch_async(self.queue, ^{
        VZNetworkTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        transaction.requestMechanism = mechanism;
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

#pragma mark Notification Posting

- (void)postNewTransactionNotificationWithTransaction:(VZNetworkTransaction *)transaction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{ kVZNetworkRecorderUserInfoTransactionKey : transaction };
        [[NSNotificationCenter defaultCenter] postNotificationName:kVZNetworkRecorderNewTransactionNotification object:self userInfo:userInfo];
    });
}

- (void)postUpdateNotificationForTransaction:(VZNetworkTransaction *)transaction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{ kVZNetworkRecorderUserInfoTransactionKey : transaction };
        [[NSNotificationCenter defaultCenter] postNotificationName:kVZNetworkRecorderTransactionUpdatedNotification object:self userInfo:userInfo];
    });
}
@end
