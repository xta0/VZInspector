//
//  VZInspectorNetworkDetailView.h
//  VZInspector
//
//  Created by moxin on 15/4/15.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VZInspectorNetworkDetailView <NSObject>

- (void)onDetailBack;
@end

@class VZNetworkTransaction;
@interface VZInspectorNetworkDetailView : UIView

@property(nonatomic,strong) VZNetworkTransaction* transaction;
@property(nonatomic,weak) id<VZInspectorNetworkDetailView> delegate;

@end
