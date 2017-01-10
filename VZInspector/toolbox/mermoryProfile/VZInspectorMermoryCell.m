//
//  VZInspectorMermoryCell.m
//  APInspector
//
//  Created by 净枫 on 2016/12/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorMermoryCell.h"
#import "VZInspectorMermoryItem.h"
#import "VZInspectorMermoryUtil.h"
#import "VZInspectorUtility.h"
#import "VZDefine.h"

@interface VZInspectorMermoryCell()

@property (nonatomic, strong) UILabel *classNameLabel;

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation VZInspectorMermoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        _classNameLabel = [VZInspectorUtility simpleLabel:CGRectMake(15, 0, screen_width - 35, KVZInspectorMermoryCellHeight) f:15 tc:VZ_RGB(0x888888) t:@""];
        
        [self addSubview:_classNameLabel];
        
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_loadingView setFrame:CGRectMake( screen_width - 30 , (KVZInspectorMermoryCellHeight -20)/2,20,20)];
        _loadingView.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
        _loadingView.tag = 19999;
        _loadingView.color = VZ_INSPECTOR_MAIN_COLOR;
        _loadingView.hidden = YES;
        [_loadingView stopAnimating];
        [self addSubview:_loadingView];
        
    }
    
    return self;
}

- (void)setItem:(VZInspectorMermoryItem *)item{
    
    if(![item isKindOfClass:[VZInspectorMermoryItem class]]){
        return;
    }
    
    if(item.retainCycleStatus == VZInspectorMermoryStatusUnknown){
        self.backgroundColor = [UIColor clearColor];
        _classNameLabel.textColor = VZ_RGB(0x888888);
        _loadingView.color = VZ_INSPECTOR_MAIN_COLOR;
    }else if(item.retainCycleStatus == VZInspectorMermoryStatusLeaked){
        self.backgroundColor = VZ_RGB(0xff6600);
        _classNameLabel.textColor = VZ_RGB(0xffffff);
        _loadingView.color = VZ_RGB(0xffffff);
    }else if(item.retainCycleStatus == VZInspectorMermoryStatusNotLeaked){
        self.backgroundColor = VZ_RGB(0x87d068);
        _classNameLabel.textColor = VZ_RGB(0xffffff);
        _loadingView.color = VZ_RGB(0xffffff);
    }else{
        self.backgroundColor = [UIColor clearColor];
        _classNameLabel.textColor = VZ_RGB(0x888888);
        _loadingView.color = VZ_INSPECTOR_MAIN_COLOR;
    }
    
    if(item.isLoading){
        _loadingView.hidden = NO;
        [_loadingView startAnimating];
    }else{
        _loadingView.hidden = YES;
        [_loadingView stopAnimating];
    }
    
    NSString *className = @"";
    if(item.objectCount > 0){
        className = [NSString stringWithFormat:@"%@ ( %d )" , item.className?:@"" , item.objectCount];
    }else{
        className = item.className?:@"";
    }
    _classNameLabel.text = className;
}

@end
