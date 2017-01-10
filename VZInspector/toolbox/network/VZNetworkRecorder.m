//
//  VZNetworkObserver.m
//  Derived from:
//
//  Flipboard
//  Created by Ryan Olson on 2/4/15.
//  Copyright (c) 2015 Flipboard. All rights reserved.
//

#import "VZNetworkRecorder.h"
#import "VZNetworkTransaction.h"
#import "VZNetworkInspector.h"
#import <zlib.h>
#import <dlfcn.h>


@interface NSData(VZGzip)

- (NSData* )vz_getGzipData;

@end


@interface VZNetworkRecorder ()

@property (nonatomic, strong) NSCache *responseCache;
@property (nonatomic, strong) NSCache* requestCache;
@property (nonatomic, strong) NSMutableArray *orderedTransactions;
@property (nonatomic, strong) NSMutableDictionary *networkTransactionsForRequestIdentifiers;

@end


@implementation VZNetworkRecorder
{
    dispatch_queue_t _queue;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.responseCache = [[NSCache alloc] init];
        [self.responseCache setTotalCostLimit:45 * 1024 * 1024];
        
        self.requestCache = [[NSCache alloc]init];
        [self.requestCache setTotalCostLimit:15 * 1024 * 1024];
        
        
        self.orderedTransactions = [NSMutableArray array];
        self.networkTransactionsForRequestIdentifiers = [NSMutableDictionary dictionary];
        
        // Serial queue used because we use mutable objects that are not thread safe
        _queue = dispatch_queue_create("com.VZ.VZNetworkRecorder", DISPATCH_QUEUE_SERIAL);
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
}

- (NSArray *)networkTransactions
{
    __block NSArray *transactions = nil;
    dispatch_sync(_queue, ^{
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
    dispatch_async(_queue, ^{
        [self.responseCache removeAllObjects];
        [self.orderedTransactions removeAllObjects];
        [self.networkTransactionsForRequestIdentifiers removeAllObjects];
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
    
    dispatch_async(_queue, ^{
        VZNetworkTransaction *transaction = [[VZNetworkTransaction alloc] init];
        transaction.requestID = requestID;
        transaction.request = request;
        transaction.startTime = startDate;
        
        [self.orderedTransactions insertObject:transaction atIndex:0];
        [self.networkTransactionsForRequestIdentifiers setObject:transaction forKey:requestID];
        transaction.transactionState = VZNetworkTransactionStateAwaitingResponse;

    });
}

- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response
{
    NSDate *responseDate = [NSDate date];
    
    dispatch_async(_queue, ^{
        VZNetworkTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        transaction.response = response;
        transaction.transactionState = VZNetworkTransactionStateReceivingData;
        transaction.latency = -[transaction.startTime timeIntervalSinceDate:responseDate];
    });
}

- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength
{
    dispatch_async(_queue, ^{
        VZNetworkTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        transaction.receivedDataLength += dataLength;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kVZNetworkInspectorRequestNotification object:nil userInfo:@{@"data-len":@(dataLength)}];
    });
}

- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody
{
    NSDate *finishedDate = [NSDate date];
    
    dispatch_async(_queue, ^{
        VZNetworkTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = VZNetworkTransactionStateFinished;
        transaction.duration = -[transaction.startTime timeIntervalSinceDate:finishedDate];
        
        //calculate gzip length
        transaction.gzipDataLength = [responseBody vz_getGzipData].length;
        
        //兼容json，html，protocol buffer三种格式和图片
        NSArray* shouldCacheMIMETypePrefixes = @[
                                                 @"application/json",
                                                 @"text/plain",
                                                 @"text/html",
                                                 @"application/protobuf",
                                                 @"text/json",
                                                 @"image/png",
                                                 @"image/gif",
                                                 @"image/webp",
                                                 @"image/jpeg",
                                                 @"application/octet-stream"];
        for (NSString* prefix in shouldCacheMIMETypePrefixes)
        {
            if([transaction.response.MIMEType hasPrefix:prefix] && responseBody.length > 0)
            {
//                NSString* contentType =  [transaction.request valueForHTTPHeaderField:@"Content-Type"];
//                if ([contentType isEqualToString:@"application/protobuf"]) {
//                    
//                }

                [self.responseCache setObject:responseBody forKey:requestID cost:[responseBody length]];
            }
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:kVZNetworkInspectorRequestFinishedNotification object:nil userInfo:@{ @"transaction":transaction}];
        
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
    });
}

- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error
{
    dispatch_async(_queue, ^{
        VZNetworkTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = VZNetworkTransactionStateFailed;
        transaction.duration = -[transaction.startTime timeIntervalSinceNow];
        transaction.error = error;
    });
}

- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID
{
    dispatch_async(_queue, ^{
        VZNetworkTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        transaction.requestMechanism = mechanism;
    });
}


@end


@implementation NSData(VZGzip)

- (NSData* )vz_getGzipData
{
    
    if (self.length == 0 || [self isGzippedData])
    {
        return self;
    }
    
    static void *libz;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        libz = dlopen("/usr/lib/libz.dylib", RTLD_LAZY);
    });
    int (*deflateInit2_)(z_streamp, int, int, int, int, int, const char *, int) =
    (int (*)(z_streamp, int, int, int, int, int, const char *, int))dlsym(libz, "deflateInit2_");
    int (*deflate)(z_streamp, int) = (int (*)(z_streamp, int))dlsym(libz, "deflate");
    int (*deflateEnd)(z_streamp) = (int (*)(z_streamp))dlsym(libz, "deflateEnd");
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uint)self.length;
    stream.next_in = (Bytef *)(void *)self.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;
    
    static const NSUInteger ChunkSize = 16384;
    
    NSMutableData *output = nil;
    int compression = 6;
    if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK)
    {
        output = [NSMutableData dataWithLength:ChunkSize];
        while (stream.avail_out == 0)
        {
            if (stream.total_out >= output.length)
            {
                output.length += ChunkSize;
            }
            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            deflate(&stream, Z_FINISH);
        }
        deflateEnd(&stream);
        output.length = stream.total_out;
    }
    
    return output;
}

- (BOOL)isGzippedData
{
    const UInt8 *bytes = (const UInt8 *)self.bytes;
    return (self.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b);
}

@end

