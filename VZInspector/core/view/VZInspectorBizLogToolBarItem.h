//
//  VZInspectorBizLogToolBarItem.h
//  APInspector
//
//  Created by 净枫 on 2016/12/12.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VZInspectorBizLogToolBarItem : NSObject

@property(nonatomic, strong)NSString *normalTitle;

@property(nonatomic, strong)NSString *selectedTitle;

@property(nonatomic, strong)UIColor *normalTitleColor;

@property(nonatomic, strong)UIColor *selectedTitleColor;

@property(nonatomic, strong)UIColor *normalBackgroundColor;

@property(nonatomic, strong)UIColor *selectedbackgroundColor;

@property(nonatomic, strong)UIColor *normalBorderColor;

@property(nonatomic, strong)UIColor *selectedBorderColor;

@property(nonatomic, assign)BOOL isSelected;

//这里不会有其他其他状态的改变，只会把当前点击的返回
@property(nonatomic, assign)BOOL onlyClick;

@property(nonatomic, assign) NSUInteger type;

// groupId 为0 表示互不影响，可以共存， 如果groupId > 0 ，则按groupId分组,分组内的东西互斥
@property(nonatomic, assign) NSUInteger groupId;

+ (VZInspectorBizLogToolBarItem *)normalToolBarItemWithNormalTitle:(NSString *)normalTitle selectedTitle:(NSString *)selectedTitle type:(NSUInteger)type isSelected:(BOOL)isSelected groupId:(NSUInteger)groupId;

+ (VZInspectorBizLogToolBarItem *)normalToolBarItemWithNormalTitle:(NSString *)normalTitle selectedTitle:(NSString *)selectedTitle type:(NSUInteger)type isSelected:(BOOL)isSelected;

+ (VZInspectorBizLogToolBarItem *)normalToolBarItemWithNormalTitle:(NSString *)normalTitle selectedTitle:(NSString *)selectedTitle type:(NSUInteger)type onlyClick:(BOOL)onlyClick;

@end
