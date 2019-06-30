//
//  Copyright © 2016年 Vizlab. All rights reserved.
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
