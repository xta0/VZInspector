//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZFrameRateOverlay : UIWindow

+(instancetype)sharedInstance;
+(void)start;
+(void)stop;

@end
