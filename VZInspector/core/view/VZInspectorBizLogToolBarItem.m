//
//  VZInspectorBizLogToolBarItem.m
//  APInspector
//
//  Created by 净枫 on 2016/12/12.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorBizLogToolBarItem.h"
#import "VZDefine.h"

@implementation VZInspectorBizLogToolBarItem

- (instancetype)init{
    if(self = [super init]){
        _normalTitleColor = VZ_RGB(0x000000);
        _normalBackgroundColor = VZ_RGB(0xffffff);
        _normalBorderColor = VZ_RGB(0xbdc8d0);
        _selectedBorderColor = VZ_INSPECTOR_MAIN_COLOR;
        _groupId = 0;
    }
    return self;
}

+ (VZInspectorBizLogToolBarItem *)normalToolBarItemWithNormalTitle:(NSString *)normalTitle selectedTitle:(NSString *)selectedTitle type:(NSUInteger)type isSelected:(BOOL)isSelected groupId:(NSUInteger)groupId{
    VZInspectorBizLogToolBarItem *item = [VZInspectorBizLogToolBarItem new];
    item.normalTitle = normalTitle;
    item.selectedTitle = selectedTitle;
    item.isSelected = isSelected;
    item.groupId = groupId;
    item.type = type;
    
    return item;
}

+ (VZInspectorBizLogToolBarItem *)normalToolBarItemWithNormalTitle:(NSString *)normalTitle selectedTitle:(NSString *)selectedTitle type:(NSUInteger)type isSelected:(BOOL)isSelected{
    return [self.class normalToolBarItemWithNormalTitle:normalTitle selectedTitle:selectedTitle type:type isSelected:isSelected groupId:0];
}

+ (VZInspectorBizLogToolBarItem *)normalToolBarItemWithNormalTitle:(NSString *)normalTitle selectedTitle:(NSString *)selectedTitle type:(NSUInteger)type onlyClick:(BOOL)onlyClick{
    VZInspectorBizLogToolBarItem *item = [self.class normalToolBarItemWithNormalTitle:normalTitle selectedTitle:selectedTitle type:type isSelected:NO groupId:0];
    item.onlyClick = onlyClick;
    return item;
}

@end
