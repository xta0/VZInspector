//
//  VZLogInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-12-16.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kVZDefaultNumberOfLogs 20

@interface VZLogInspectorEntity:NSObject

@property (nonatomic, strong)   NSDate *date;
@property (nonatomic, copy)     NSString *sender;
@property (nonatomic, copy)     NSString *messageText;
@property (nonatomic, assign)   long long messageID;

@end

@interface VZLogInspector : NSObject

+ (instancetype) sharedInstance;

+ (void)setNumberOfLogs:(NSUInteger)num;

+ (NSArray* )logs;

+ (NSAttributedString* )logsString;


@end
