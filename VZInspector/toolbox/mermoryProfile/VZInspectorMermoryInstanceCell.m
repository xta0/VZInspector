//
//  VZInspectorMermoryInstanceCell.m
//  APInspector
//
//  Created by 净枫 on 2016/12/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorMermoryInstanceCell.h"
#import "VZInspectorMermoryRetainCycleResultItem.h"
#import "VZInspectorUtility.h"
#import "VZDefine.h"

@interface VZInspectorMermoryInstanceCell()

@property (nonatomic, strong) UILabel *classNameLabel;

@end

@implementation VZInspectorMermoryInstanceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        _classNameLabel = [VZInspectorUtility simpleLabel:CGRectZero f:15 tc:VZ_RGB(0x888888) t:@""];
        _classNameLabel.numberOfLines = 0;
        
        [self addSubview:_classNameLabel];
        
    }
    
    return self;
}

- (void)setItem:(VZInspectorMermoryRetainCycleResultItem *)item{
    
    if(![item isKindOfClass:[VZInspectorMermoryRetainCycleResultItem class]]){
        return;
    }
    
    _classNameLabel.frame = CGRectMake(15, 5, screen_width - 30, item.describleSize.height);
    
    _classNameLabel.text = vz_IsStringValid([item retainCycleDescrible]) ? [item retainCycleDescrible] :@"";
}


@end
