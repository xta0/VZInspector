//
//  VZLogInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-12-16.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZLogInspector : NSObject

+ (VZLogInspector* )sharedInstance;

+ (void)setRequestLogIdentifier:(NSString* )identifier;
+ (NSString* )requestLogIdentifier;

+ (void)setResponseLogIdentifier:(NSString* )identifier;
+ (NSString* )responseLogIdentifier;

+ (void)setRequestLogURLPath:(NSString* )path;
+ (NSString* )requestLogURLPath;

+ (void)setResponseLogStringPath:(NSString* )path;
+ (NSString* )responseLogStringPath;

+ (void)setResponseLogErrorPath:(NSString* )path;
+ (NSString* )responseLogErrorPath;


@end
