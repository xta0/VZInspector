// VZViewControllerLogic.h 
// Vizzle
// created by Jayson Xu on 2014-09-15 15:35:19 +0800.
// Copyright (c) @VizLab. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class VZViewController;

@protocol VZViewControllerLogicInterface <NSObject>

@optional
- (void)onControllerShouldPerformAction:(int)type args:(NSDictionary* )dict;

@end

@interface VZViewControllerLogic : NSObject

@property(nonatomic,weak)id<VZViewControllerLogicInterface> viewController;

- (void)logic_view_did_load;

- (void)logic_view_will_appear;

- (void)logic_view_did_appear;

- (void)logic_view_will_disappear;

- (void)logic_view_did_disappear;

- (void)logic_dealloc;


@end
