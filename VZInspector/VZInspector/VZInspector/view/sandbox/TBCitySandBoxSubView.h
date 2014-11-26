//
//  TBCitySandBoxSubView.h
//  iCoupon
//
//  Created by moxin.xt on 14-10-11.
//  Copyright (c) 2014年 Taobao.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBCitySandBoxItem : NSObject

@property(nonatomic,strong) NSString* name;
@property(nonatomic,strong) NSString* path;

@end


@protocol TBCitySandBoxSubViewCallBackProtocol  <NSObject>

@optional
- (void)onSubViewDidSelect:(NSInteger)index FileName:(NSString* )file;

@end

@interface TBCitySandBoxSubView : UIView

@property(nonatomic,weak) id<TBCitySandBoxSubViewCallBackProtocol> delegate;
@property(nonatomic,strong)NSString* currentDir;

- (id)initWithFrame:(CGRect)frame Dir:(NSString* )dir;

@end
