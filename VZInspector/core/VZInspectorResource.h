//
//  VZInspectorResource.h
//  VZInspector
//
//  Created by moxin on 15/4/17.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define VZ_IMAGE(BYTE_ARRAY)                [VZInspectorResource imageWithBytes:BYTE_ARRAY length:sizeof(BYTE_ARRAY)]
#define VZ_IMAGE_SCALE(BYTE_ARRAY, SCALE)   [VZInspectorResource imageWithBytes:BYTE_ARRAY length:sizeof(BYTE_ARRAY) scale:SCALE]

@interface VZInspectorResource : NSObject

+ (UIImage *)imageWithBytes:(const uint8_t *)bytes length:(size_t)length;
+ (UIImage *)imageWithBytes:(const uint8_t *)bytes length:(size_t)length scale:(CGFloat)scale;

+ (UIImage *)logo;

+ (UIImage *)eye;

+ (UIImage *)grid;

+ (UIImage *)sandbox;

+ (UIImage *)network_logs;

+ (UIImage *)crash;

+ (UIImage *)heap;

+ (UIImage *)memoryWarning;

+ (UIImage *)border;

+ (UIImage *)viewClass;

+ (UIImage *)image;

+ (UIImage *)location;

+ (UIImage *)frameRate;

+ (UIImage *)behaviorLog;

+ (UIImage *)asyncIcon;

+ (UIImage *)colorPickerIcon;

+ (UIImage *)tipIcon;

+ (UIImage *)schemeManagerIcon;

+ (UIImage *)scanIcon;

+ (UIImage *)pluginIcon;

+ (UIImage *)searchBarIcon;

+ (UIImage *)mermoryArrowIcon;


@end
