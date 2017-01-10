//
//  VZInspectorSandBoxSubView.h
//  iCoupon
//
//  Created by moxin.xt on 14-10-11.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZInspectorSandBoxItem : NSObject

@property(nonatomic,strong) NSString* name;
@property(nonatomic,strong) NSString* path;

@end


@protocol VZInspectorSandBoxSubViewCallBackProtocol  <NSObject>

@optional
- (void)onSubViewDidSelect:(NSInteger)index FileName:(NSString* )file;
@end

@interface VZInspectorSandBoxSubView : UIView

@property(nonatomic,weak) id<VZInspectorSandBoxSubViewCallBackProtocol> delegate;
@property(nonatomic,strong)NSString* currentDir;

- (id)initWithFrame:(CGRect)frame dir:(NSString* )dir appendBundle:(BOOL)appendBundle;

@end
