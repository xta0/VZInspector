//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import "VZInspectorView.h"

@protocol VZInspectorCrashViewCallBackProtocol  <NSObject>

@optional
- (void)onBack;


@end


@interface VZInspectorCrashView : VZInspectorView

@property(nonatomic,weak) id<VZInspectorCrashViewCallBackProtocol> delegate;
@property(nonatomic,strong) NSString* path;


@end
