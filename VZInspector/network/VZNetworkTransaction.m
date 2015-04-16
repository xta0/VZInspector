//
//  VZNetworkTransaction.m
//  VZInspector
//
//  Created by moxin on 15/4/15.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import "VZNetworkTransaction.h"

@implementation VZNetworkTransaction

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

@end
