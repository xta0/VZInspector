//
//  VZInspectorTimer.h
//  VZInspector
//
//  Created by moxin on 15/4/20.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^vz_inspectorTimerReadCallback)(void);
typedef void(^vz_inspectorTimerWriteCallback)(void) ;

@interface VZInspectorTimer : NSObject

@property(nonatomic,copy) vz_inspectorTimerReadCallback readCallback;
@property(nonatomic,copy) vz_inspectorTimerWriteCallback writeCallback;

+ (instancetype)sharedInstance;

- (void)startTimer;

- (void)stopTimer;


@end
