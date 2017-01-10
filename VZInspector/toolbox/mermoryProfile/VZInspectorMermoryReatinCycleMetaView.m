//
//  VZInspectorMermoryReatinCycleMetaView.m
//  APInspector
//
//  Created by 净枫 on 2016/12/21.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorMermoryReatinCycleMetaView.h"
#import "VZDefine.h"
#import "VZInspectorUtility.h"


@interface VZInspectorMermoryReatinCycleMetaView()

@property (nonatomic, strong) UILabel *classNameLabel;

@property (nonatomic, strong) UILabel *variableLabel;

@end

@implementation VZInspectorMermoryReatinCycleMetaView

- (instancetype)initWithFrame:(CGRect)frame item:(VZInspectorMermoryRetainCycleItem *)item{
    
    CGFloat classNameWidth = 0;
    CGFloat variableWidth = 0;
    if(item.variableClassName){
        classNameWidth = ceilf(VZ_TextSizeFrame(item.variableClassName, 15).width);
    }
    
    if(item.variable){
        variableWidth = ceilf(VZ_TextSizeFrame(item.variable, 13).width);
    }
    
    CGFloat maxWidth = (classNameWidth > variableWidth ? classNameWidth : variableWidth) + (item.isFirstOrLast ? 36 : 20);
    
    CGRect contentFrame = CGRectMake(0, 0, maxWidth, 45);
    if(self = [super initWithFrame:contentFrame]){
        
        _classNameLabel = [VZInspectorUtility simpleLabel:CGRectMake(0, 0, maxWidth, 36) f:15 tc:VZ_RGB(0xffffff) t:item.variableClassName?:@""];
        _classNameLabel.textAlignment = NSTextAlignmentCenter;
        _classNameLabel.backgroundColor = item.backgroundColor ?:VZ_RGB(0xfb6165);
        if(item.isFirstOrLast){
            _classNameLabel.layer.cornerRadius = 18;
            _classNameLabel.clipsToBounds = YES;
        }
        [self addSubview:_classNameLabel];
        
        if(vz_IsStringValid(item.variable)){
            _variableLabel = [VZInspectorUtility simpleLabel:CGRectMake((maxWidth - variableWidth - 10) /2, 45 - 18  , variableWidth + 10, 18) f:13 tc:VZ_RGB(0xffffff) t:item.variable?:@""];
            _variableLabel.textAlignment = NSTextAlignmentCenter;
            _variableLabel.layer.borderColor =VZ_RGB(0xfd8023).CGColor;
            _variableLabel.backgroundColor =VZ_RGB(0xfd8023);
            [self addSubview:_variableLabel];
        }
        
    }
    return self;
}

@end
