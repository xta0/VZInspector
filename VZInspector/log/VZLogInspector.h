//
//  VZLogInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-12-16.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kVZDefaultNumberOfLogs 20

@class VZLogInspectorEntity;
@protocol VZLogInspectorDelegate <NSObject>

- (void)logMessage:(VZLogInspectorEntity *)message;

@end

@interface VZLogInspectorEntity:NSObject

@property (nonatomic, strong)   NSDate *date;
@property (nonatomic, copy)     NSString *sender;
@property (nonatomic, copy)     NSString *messageText;
@property (nonatomic, assign)   long long messageID;
@property (nonatomic, assign) NSUInteger level;
@end

@interface VZLogInspector : NSObject

@property(nonatomic,copy) NSArray *searchList;

+ (instancetype) sharedInstance;

@property (nonatomic, strong) NSMutableArray *observers;

@property (nonatomic, assign) id<VZLogInspectorDelegate> delegate;

+ (void)setNumberOfLogs:(NSUInteger)num;

+ (NSArray* )logs;

+ (NSAttributedString* )logsString:(NSString *)searchkey;

+(NSAttributedString *)formatLog:(VZLogInspectorEntity *)entity searchkey:(NSString *)searchKey;

+ (void)start;

+ (void)stop;

- (void)addObserver:(id<VZLogInspectorDelegate>)observer;

- (void)removeObserver:(id<VZLogInspectorDelegate>)observer;
@end
