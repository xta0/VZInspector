//
//  VZLogInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-12-16.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZLogInspector.h"

@interface VZLogInspector()

@property(nonatomic,strong)NSString* requestLogId;
@property(nonatomic,strong)NSString* responseLogId;
@property(nonatomic,strong)NSString* requestURLPath;
@property(nonatomic,strong)NSString* responseStringPath;
@property(nonatomic,strong)NSString* responseErrorPath;

@end

@implementation VZLogInspector

+ (VZLogInspector* )sharedInstance
{
    static VZLogInspector* instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [VZLogInspector new];
    });
    
    return instance;
}

+ (void)setRequestLogIdentifier:(NSString* )identifier
{
    [self sharedInstance].requestLogId = identifier;
}
+ (NSString* )requestLogIdentifier
{
    return [self sharedInstance].requestLogId ?: @"";
}

+ (void)setResponseLogIdentifier:(NSString* )identifier
{
    [self sharedInstance].responseLogId = identifier;
}
+ (NSString* )responseLogIdentifier
{
    return [self sharedInstance].responseLogId?:@"";
}

+ (void)setRequestLogURLPath:(NSString* )path
{
    [self sharedInstance].requestURLPath = path;
}
+ (NSString* )requestLogURLPath
{
    return [self sharedInstance].requestURLPath?:@"";
}

+ (void)setResponseLogStringPath:(NSString* )path
{
    [self sharedInstance].responseStringPath = path;
}
+ (NSString* )responseLogStringPath
{
    return [self sharedInstance].responseStringPath?:@"";
}

+ (void)setResponseLogErrorPath:(NSString* )path
{
    [self sharedInstance].responseErrorPath = path;

}
+ (NSString* )responseLogErrorPath
{
    return [self sharedInstance].responseErrorPath?:@"";
}

@end
