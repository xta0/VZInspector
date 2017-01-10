//
//  VZInspectorUtility.h
//  VZInspector
//
//  Created by moxin on 15/4/15.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VZNetworkTransaction;

@interface VZInspectorUtility : NSObject

+ (NSDictionary *)dictionaryFromQuery:(NSString *)query;

+ (NSString *)prettyJSONStringFromData:(NSData *)data;

+ (NSString *)prettyJSONStringFromObject:(id)jsonObject;

+ (NSString *)prettyStringFromRequestBodyForTransaction:(VZNetworkTransaction *)transaction;

+ (NSString *)prettyStringFromResponseBodyForTransaction:(VZNetworkTransaction *)transaction;

+ (NSString *)timestampStringFromRequestDate:(NSDate *)date;

+ (NSString *)stringFromRequestDuration:(NSTimeInterval)duration;

+ (NSString *)statusCodeStringFromURLResponse:(NSURLResponse *)response;

+ (NSData *)inflatedDataFromCompressedData:(NSData *)compressedData;

+ (NSString *)stringFormatFromDate:(NSDate *)date;

+ (UIColor* )themeColor;

+ (UIColor* )blueColor;

+ (UILabel *)simpleLabel:(CGRect)frame f:(int)size tc:(UIColor *)color t:(NSString *)text;

+ (UILabel *)simpleBorderLabel:(CGRect)frame f:(int)size tc:(UIColor *)color t:(NSString *)text;

+ (UIButton *)simpleButton:(CGRect)frame f:(int)size tc:(UIColor *)color t:( NSString *)text;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (BOOL)validateRegularExpression:(NSString *)pattern string:(NSString *)string;

+ (BOOL)isNumber:(NSString *)string;

+ (UIWindow *)mainWindow ;

@end

extern void VZSwapClassMethods(Class cls, SEL original, SEL replacement);

extern void VZSwapInstanceMethods(Class cls, SEL original, SEL replacement);
