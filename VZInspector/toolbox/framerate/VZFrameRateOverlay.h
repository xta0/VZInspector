//
//  VZFrameRateOverlay.h
//  VZInspector
//
//  Created by lingwan on 15/9/8.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZFrameRateOverlay : UIWindow

+(instancetype)sharedInstance;
+(void)start;
+(void)stop;

@end
