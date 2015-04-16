//
//  VZInspectorUtility.h
//  VZInspector
//
//  Created by moxin on 15/4/15.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VZInspectorUtility : NSObject

+ (NSDictionary *)dictionaryFromQuery:(NSString *)query;

+ (NSString *)prettyJSONStringFromData:(NSData *)data;

+ (NSString *)timestampStringFromRequestDate:(NSDate *)date;

+ (NSString *)stringFromRequestDuration:(NSTimeInterval)duration;

+ (NSString *)statusCodeStringFromURLResponse:(NSURLResponse *)response;

+ (NSData *)inflatedDataFromCompressedData:(NSData *)compressedData;

+ (NSString *)stringFormatFromDate:(NSDate *)date;

+ (float) heightForText:(NSString* )text withConstrainedWidth:(NSInteger)width Font:(UIFont* )font;

@end
