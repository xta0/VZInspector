//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VZNetworkTransaction.h"

extern  NSString* const kVZNetworkInspectorRequestNotification;
extern  NSString* const kVZNetworkInspectorRequestFinishedNotification;

typedef NSString *(^TransactionTitleFilter)(VZNetworkTransaction *transaction);
typedef NSString *(^VZNetworkDecoder)(VZNetworkTransaction *transaction, NSData *data);

@interface VZNetworkInspector : NSObject
+ (instancetype)sharedInstance;

@property(nonatomic,assign) size_t totalResponseBytes;
@property(nonatomic,assign) NSInteger totalNetworkCount;

- (void)addTransactionTitleFilter:(TransactionTitleFilter)filter;
- (NSArray *)transactionTitleFilters;
+ (void)setIgnoreDelegateClasses:(NSSet *)classes;

- (void)addRequestDecoder:(VZNetworkDecoder)decoder;
- (void)addResponseDecoder:(VZNetworkDecoder)decoder;

@property (nonatomic, strong, readonly) NSMutableArray<VZNetworkDecoder> *requestDecoders;
@property (nonatomic, strong, readonly) NSMutableArray<VZNetworkDecoder> *responseDecoders;

- (NSString *)decodeRequestData:(NSData *)data withTransaction:(VZNetworkTransaction *)transaction;
- (NSString *)decodeResponseData:(NSData *)data withTransaction:(VZNetworkTransaction *)transaction;

@end
