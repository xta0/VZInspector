//
//  VZNetworkObserver.h
//  Derived from:
//
//  VZNetworkTransaction
//  Flipboard
//
//  Created by Ryan Olson on 2/8/15.
//  Copyright (c) 2015 Flipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VZNetworkTransactionState) {
    VZNetworkTransactionStateUnstarted,
    VZNetworkTransactionStateAwaitingResponse,
    VZNetworkTransactionStateReceivingData,
    VZNetworkTransactionStateFinished,
    VZNetworkTransactionStateFailed
};

@interface VZNetworkTransaction : NSObject

@property (nonatomic, copy) NSString *requestID;

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, copy) NSString *requestMechanism;
@property (nonatomic, assign) VZNetworkTransactionState transactionState;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, assign) NSTimeInterval latency;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) int64_t gzipDataLength;
@property (nonatomic, assign) int64_t receivedDataLength;

@property (nonatomic, strong, readonly) NSData *postBodyData;

/// Only applicable for image downloads. A small thumbnail to preview the full response.
//@property (nonatomic, strong) UIImage *responseThumbnail;

@end
