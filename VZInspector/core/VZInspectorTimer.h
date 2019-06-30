//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import <Foundation/Foundation.h>


extern const  NSString* kVZTimerReadCallbackString;
extern const  NSString* kVZTimerWriteCallbackString;
extern const  NSString* kVZTimerStartCallbackString;
extern const  NSString* kVZTimerStopCallbackString;

typedef void(^vz_inspectorTimerReadCallback)(void);
typedef void(^vz_inspectorTimerWriteCallback)(void) ;

@interface VZInspectorTimer : NSObject

@property(nonatomic,copy) vz_inspectorTimerReadCallback readCallback;
@property(nonatomic,copy) vz_inspectorTimerWriteCallback writeCallback;

+ (instancetype)sharedInstance;

- (void)startTimer;

- (void)stopTimer;


@end
