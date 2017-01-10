//
//  VZInspectorBizLogManager.h
//  APInspector
//
//  Created by 净枫 on 16/6/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VZInspectorBizLogView.h"

@interface VZInspectorBizLogManager : NSObject

@property (nonatomic, strong) VZInspectorBizLogView *logView;


+ (instancetype)sharedInstance ;

- (void)show;

- (void)hide;

- (void)toggle;

- (void)onClickClearButton;

- (void)onClickCancleButton;

- (BOOL)isShowing;
@end
