//
//  VZNetworkResponseView.h
//  VZInspector
//
//  Created by moxin on 15/4/15.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VZNetworkTransaction;
@interface VZInspectorNetworkResponseView : UIView

@property(nonatomic,strong)VZNetworkTransaction* transaction;
@property(nonatomic,assign)BOOL showPostRequestBody;
@property(nonatomic,assign)BOOL showResponse;

@end
