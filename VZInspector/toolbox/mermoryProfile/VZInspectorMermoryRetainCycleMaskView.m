//
//  VZInspectorMermoryRetainCycleMaskView.m
//  APInspector
//
//  Created by 净枫 on 2016/12/21.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorMermoryRetainCycleMaskView.h"
#import "VZInspectorMermoryRetainCycleItem.h"
#import "VZInspectorMermoryReatinCycleMetaView.h"
#import "VZInspectorResource.h"
#import <Foundation/Foundation.h>
#import "VZDefine.h"
#import "VZInspectorResource.h"
#import "VZInspectorUtility.h"

@interface VZInspectorMermoryRetainCycleMaskView()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation VZInspectorMermoryRetainCycleMaskView

- (instancetype)initWithFrame:(CGRect)frame rootView:(UIView *)rootView data:(VZInspectorMermoryRetainCycleResultItem *)item{
    CGRect contentFrame = rootView.frame;
    if(self = [super initWithFrame:contentFrame rootView:rootView]){
        
        self.contentView.backgroundColor = [UIColor whiteColor];

         CGFloat yoffsex = 20;
        CGFloat contentWidth = contentFrame.size.width;
        
        _titleLabel = [VZInspectorUtility simpleLabel:CGRectMake(15, yoffsex, contentFrame.size.width - 30 , 21) f:15 tc:VZ_INSPECTOR_MAIN_COLOR t:@"循环依赖关系图"] ;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
        
        yoffsex += 21 + 8 ;
        UIView *titleLine = [[UIView alloc]initWithFrame:CGRectMake(15, yoffsex, contentFrame.size.width - 30, kOnePix)];
        titleLine.backgroundColor = VZ_INSPECTOR_MAIN_COLOR;
        [self.contentView addSubview:titleLine];
        
        yoffsex += 4;
        
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yoffsex, contentFrame.size.width, contentFrame.size.height - yoffsex)];
        
        [self.contentView addSubview:_scrollView];
        
        __block CGFloat scrollViewYOffsex = 0;
        
        NSUInteger count = item.retainCycleDatas.count;
        [item.retainCycleDatas enumerateObjectsUsingBlock:^(VZInspectorMermoryRetainCycleItem *retainCycleItem, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(idx == 0){
                retainCycleItem.backgroundColor = VZ_RGB(0xff6600);
                retainCycleItem.isFirstOrLast = YES;
            }else{
                retainCycleItem.backgroundColor = VZ_RGB(0xfb6165);
                retainCycleItem.isFirstOrLast = NO;
            }
            VZInspectorMermoryReatinCycleMetaView *metaView = [[VZInspectorMermoryReatinCycleMetaView alloc] initWithFrame:CGRectZero item:retainCycleItem];
            CGSize metaViewSize = metaView.frame.size;
            CGFloat x = (contentWidth - metaViewSize.width)/2;
            metaView.frame = CGRectMake(x, scrollViewYOffsex, metaViewSize.width, metaViewSize.height);
            [_scrollView addSubview:metaView];
            
            scrollViewYOffsex += metaViewSize.height + 5;
            
            UIImageView *arrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake((contentWidth - 16)/2, scrollViewYOffsex, 16, 16)];
            arrowImageView.image = [VZInspectorResource mermoryArrowIcon];
            arrowImageView.contentMode = UIViewContentModeScaleAspectFill;
            [_scrollView addSubview:arrowImageView];
            
            scrollViewYOffsex += 16 + 5;
            
            if(idx == count -1){
                VZInspectorMermoryRetainCycleItem *lastItem = [VZInspectorMermoryRetainCycleItem new];
                lastItem.className = @"";
                lastItem.variable = @"";
                lastItem.variableClassName = retainCycleItem.className;
                lastItem.backgroundColor = VZ_RGB(0xff6600);
                lastItem.isFirstOrLast = YES;
                VZInspectorMermoryReatinCycleMetaView *lastMetaView = [[VZInspectorMermoryReatinCycleMetaView alloc] initWithFrame:CGRectZero item:lastItem];
                CGSize lastMetaViewSize = lastMetaView.frame.size;
                CGFloat x = (contentWidth - lastMetaViewSize.width)/2;
                lastMetaView.frame = CGRectMake(x, scrollViewYOffsex, lastMetaViewSize.width, lastMetaViewSize.height);
                [_scrollView addSubview:lastMetaView];
            }
            
        }];
    }
    return self;
        
}


@end
