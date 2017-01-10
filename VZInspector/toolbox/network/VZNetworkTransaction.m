//
//  VZNetworkObserver.m
//  Derived from:
//
//  VZNetworkTransaction
//  Flipboard
//
//  Created by Ryan Olson on 2/8/15.
//  Copyright (c) 2015 Flipboard. All rights reserved.

#import "VZNetworkTransaction.h"
#import "VZInspectorUtility.h"

@implementation VZNetworkTransaction

@synthesize postBodyData = _postBodyData;

- (NSString *)description
{
    NSString *description = [super description];
    
    description = [description stringByAppendingFormat:@" id = %@;", self.requestID];
    description = [description stringByAppendingFormat:@" url = %@;", self.request.URL];
    description = [description stringByAppendingFormat:@" duration = %f;", self.duration];
    description = [description stringByAppendingFormat:@" receivedDataLength = %lld", self.receivedDataLength];
    
    NSString* stateStr = @"";
    switch (self.transactionState) {
        case VZNetworkTransactionStateUnstarted:
            stateStr = @"state = Unstarted";
            break;
            
        case VZNetworkTransactionStateAwaitingResponse:
            stateStr = @"state = Awaiting Response";
            break;
            
        case VZNetworkTransactionStateReceivingData:
            stateStr = @"state = Receiving Data";
            break;
            
        case VZNetworkTransactionStateFinished:
            stateStr = @"state = Finished";
            break;
            
        case VZNetworkTransactionStateFailed:
            stateStr = @"state = Failed";
            break;
    }
    
    return [description stringByAppendingString:stateStr];
}

- (NSData *)postBodyData
{
    if (!_postBodyData) {
        NSData *bodyData = self.request.HTTPBody;
        if ([bodyData length] > 0) {
            NSString *contentEncoding = [self.request valueForHTTPHeaderField:@"Content-Encoding"];
            if ([contentEncoding rangeOfString:@"deflate" options:NSCaseInsensitiveSearch].length > 0 || [contentEncoding rangeOfString:@"gzip" options:NSCaseInsensitiveSearch].length > 0) {
                bodyData = [VZInspectorUtility inflatedDataFromCompressedData:bodyData];
            }
        }
        _postBodyData = bodyData;
    }
    return _postBodyData;
}
    

@end
