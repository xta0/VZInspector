//
//  VZInspectorUtility.m
//  VZInspector
//
//  Created by moxin on 15/4/15.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZInspectorUtility.h"
#import <zlib.h>
#import <objc/runtime.h>
#import "VZNetworkRecorder.h"
#import "VZNetworkInspector.h"
#import "VZDefine.h"


@implementation VZInspectorUtility

+ (UIColor* )themeColor
{
    return [UIColor orangeColor];
}

+ (UIColor* )blueColor
{
    return [UIColor cyanColor];
}

+ (NSDictionary *)dictionaryFromQuery:(NSString *)query
{
    NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionary];
    
    // [a=1, b=2, c=3]
    NSArray *queryComponents = [query componentsSeparatedByString:@"&"];
    for (NSString *keyValueString in queryComponents) {
        // [a, 1]
        NSArray *components = [keyValueString componentsSeparatedByString:@"="];
        if ([components count] == 2) {
            NSString *key = [[components firstObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            id value = [[components lastObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            // Handle multiple entries under the same key as an array
            id existingEntry = [queryDictionary objectForKey:key];
            if (existingEntry) {
                if ([existingEntry isKindOfClass:[NSArray class]]) {
                    value = [existingEntry arrayByAddingObject:value];
                } else {
                    value = @[existingEntry, value];
                }
            }
            
            [queryDictionary setObject:value forKey:key];
        }
    }
    
    return queryDictionary;
}

+ (NSString *)prettyStringFromRequestBodyForTransaction:(VZNetworkTransaction *)transaction
{
    NSData *data = transaction.postBodyData;
    u_int8_t gzipBytes[] = {0x1f,0x8b,0x08,0x00};
    NSData *gzipPrefix = [NSData dataWithBytes:gzipBytes length:sizeof(gzipBytes)];
    if (data.length > 4 && [[data subdataWithRange:NSMakeRange(0, 4)] isEqualToData:gzipPrefix]) {
        NSData *deflatedData = [VZInspectorUtility inflatedDataFromCompressedData:data];
        if (deflatedData.length > 0) {
            data = deflatedData;
        }
    }
    NSString *decodedRequest = [[VZNetworkInspector sharedInstance] decodeResponseData:data withTransaction:transaction];
    if (decodedRequest) {
        return decodedRequest;
    }
    return [VZInspectorUtility prettyJSONStringFromData:data];
}

+ (NSString *)prettyStringFromResponseBodyForTransaction:(id)transaction
{
    NSData *responseData = [[VZNetworkRecorder defaultRecorder] cachedResponseBodyForTransaction:transaction];
    if ([responseData length] > 0)
    {
        NSString *decodedResponse = [[VZNetworkInspector sharedInstance] decodeResponseData:responseData withTransaction:transaction];
        if (decodedResponse) {
            return decodedResponse;
        }
        return [VZInspectorUtility prettyJSONStringFromData:responseData];
    }
    return nil;
}

+ (NSString *)prettyJSONStringFromData:(NSData *)data
{
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSString *prettyString = [self prettyJSONStringFromObject:jsonObject];
    if (!prettyString) {
        prettyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return prettyString;
}

+ (NSString *)prettyJSONStringFromObject:(id)jsonObject
{
    NSString *prettyString = nil;
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        prettyString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL] encoding:NSUTF8StringEncoding];
        // NSJSONSerialization escapes forward slashes. We want pretty json, so run through and unescape the slashes.
        prettyString = [prettyString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    }
    return prettyString;
}

+ (NSString *)timestampStringFromRequestDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm:ss";
    });
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)stringFromRequestDuration:(NSTimeInterval)duration
{
    NSString *string = @"0s";
    if (duration > 0.0) {
        if (duration < 1.0) {
            string = [NSString stringWithFormat:@"%dms", (int)(duration * 1000)];
        } else if (duration < 10.0) {
            string = [NSString stringWithFormat:@"%.2fs", duration];
        } else {
            string = [NSString stringWithFormat:@"%.1fs", duration];
        }
    }
    return string;
}

+ (NSString *)statusCodeStringFromURLResponse:(NSURLResponse *)response
{
    NSString *httpResponseString = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *statusCodeDescription = nil;
        if (httpResponse.statusCode == 200) {
            // Prefer OK to the default "no error"
            statusCodeDescription = @"OK";
        } else {
            statusCodeDescription = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
        }
        httpResponseString = [NSString stringWithFormat:@"%ld %@", (long)httpResponse.statusCode, statusCodeDescription];
    }
    return httpResponseString;
}

// Thanks to the following links for help with this method
// http://www.cocoanetics.com/2012/02/decompressing-files-into-memory/
// https://github.com/nicklockwood/GZIP
+ (NSData *)inflatedDataFromCompressedData:(NSData *)compressedData
{
    NSData *inflatedData = nil;
    NSUInteger compressedDataLength = [compressedData length];
    if (compressedDataLength > 0) {
        z_stream stream;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.avail_in = (uInt)compressedDataLength;
        stream.next_in = (void *)[compressedData bytes];
        stream.total_out = 0;
        stream.avail_out = 0;
        
        NSMutableData *mutableData = [NSMutableData dataWithLength:compressedDataLength * 1.5];
        if (inflateInit2(&stream, 15 + 32) == Z_OK) {
            int status = Z_OK;
            while (status == Z_OK) {
                if (stream.total_out >= [mutableData length]) {
                    mutableData.length += compressedDataLength / 2;
                }
                stream.next_out = (uint8_t *)[mutableData mutableBytes] + stream.total_out;
                stream.avail_out = (uInt)([mutableData length] - stream.total_out);
                status = inflate(&stream, Z_SYNC_FLUSH);
            }
            if (inflateEnd(&stream) == Z_OK) {
                if (status == Z_STREAM_END) {
                    mutableData.length = stream.total_out;
                    inflatedData = [mutableData copy];
                }
            }
        }
    }
    return inflatedData;
}

+ (NSString *)stringFormatFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });
    
    return [formatter stringFromDate:date];
}


+ (UILabel *)simpleLabel:(CGRect)frame f:(int)size tc:(UIColor *)color t:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    label.text = text;
    
    return label;
}

+ (UIButton *)simpleButton:(CGRect)frame f:(int)size tc:(UIColor *)color t:(nullable NSString *)text
{
    UIButton *tagLabel;
    tagLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    tagLabel.backgroundColor = [UIColor clearColor];
    tagLabel.frame = frame;
    tagLabel.titleLabel.font = [UIFont systemFontOfSize:size];
    tagLabel.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    tagLabel.tintColor = color;
    [tagLabel setTitleColor:tagLabel.tintColor forState:UIControlStateNormal];
    tagLabel.layer.borderColor = tagLabel.tintColor.CGColor;
    tagLabel.layer.borderWidth = 0;
    tagLabel.layer.cornerRadius = 0;
    //按钮不响应时间
    tagLabel.userInteractionEnabled = YES;
    tagLabel.clipsToBounds = YES;
    [tagLabel setTitle:text forState:UIControlStateNormal];
    return tagLabel;
}


+ (UILabel *)simpleBorderLabel:(CGRect)frame f:(int)size tc:(UIColor *)color t:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    label.layer.borderColor = color.CGColor;
    label.layer.borderWidth = 1;
    label.layer.cornerRadius = 3;
    
    return label;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (BOOL)isNumber:(NSString *)string{
    return [VZInspectorUtility validateRegularExpression:@"^[0-9]*$" string:string];
}

+ (BOOL)validateRegularExpression:(NSString *)pattern string:(NSString *)string{
    if(!vz_IsStringValid(pattern)){
        return YES;
    }
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    return ([regularexpression numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)] > 0);
}

+ (UIWindow *)mainWindow {
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate
        && [appDelegate respondsToSelector:@selector(window)]) {
        return [appDelegate window];
    }
    
    NSArray *windows = [UIApplication sharedApplication].windows;
    if (windows.count == 1) {
        return windows.firstObject;
    } else {
        for (UIWindow *window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                return window;
            }
        }
    }
    return nil;
}

@end

void VZSwapClassMethods(Class cls, SEL original, SEL replacement)
{
    Method originalMethod = class_getClassMethod(cls, original);
    IMP originalImplementation = method_getImplementation(originalMethod);
    const char *originalArgTypes = method_getTypeEncoding(originalMethod);
    
    Method replacementMethod = class_getClassMethod(cls, replacement);
    IMP replacementImplementation = method_getImplementation(replacementMethod);
    const char *replacementArgTypes = method_getTypeEncoding(replacementMethod);
    
    if (class_addMethod(cls, original, replacementImplementation, replacementArgTypes)) {
        class_replaceMethod(cls, replacement, originalImplementation, originalArgTypes);
    } else {
        method_exchangeImplementations(originalMethod, replacementMethod);
    }
}

void VZSwapInstanceMethods(Class cls, SEL original, SEL replacement)
{
    Method originalMethod = class_getInstanceMethod(cls, original);
    IMP originalImplementation = method_getImplementation(originalMethod);
    const char *originalArgTypes = method_getTypeEncoding(originalMethod);
    
    Method replacementMethod = class_getInstanceMethod(cls, replacement);
    IMP replacementImplementation = method_getImplementation(replacementMethod);
    const char *replacementArgTypes = method_getTypeEncoding(replacementMethod);
    
    if (class_addMethod(cls, original, replacementImplementation, replacementArgTypes)) {
        class_replaceMethod(cls, replacement, originalImplementation, originalArgTypes);
    } else {
        method_exchangeImplementations(originalMethod, replacementMethod);
    }
}
