//
//  VZFooterViewFactory.m
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZFooterViewFactory.h"

@implementation VZFooterViewFactory


+ (UIView*)clickableFooterView:(CGRect)frame Text:(NSString*)text Target:(id)target Action:(SEL)action
{
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    return btn;
}

+ (UIView*)normalFooterView:(CGRect)frame Text:(NSString*)text
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    // Initialization code.
    UILabel* titleLabel = [[UILabel alloc ] initWithFrame:frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = text;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor =  [UIColor grayColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    view.backgroundColor = [UIColor clearColor];
    
    [view addSubview:titleLabel];
    
    return view;
    
    
    
}
+ (UIView*)loadingFooterView:(CGRect)frame Text:(NSString*)text
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    
    CGSize textSize            = [text sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    // Initialization code.
    UILabel* titleLabel        = [[UILabel alloc ] initWithFrame:CGRectMake((view.frame.size.width-textSize.width)/2,(frame.size.height - textSize.height)/2   ,textSize.width, textSize.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text            = text;
    titleLabel.font            = [UIFont systemFontOfSize:14];
    titleLabel.textColor       = [UIColor grayColor];
    titleLabel.textAlignment   = NSTextAlignmentCenter;
    
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.color                    = [UIColor redColor];
    [activityIndicator startAnimating];
    
    if ([text isEqualToString:@""] || !text) {
        activityIndicator.frame  = CGRectMake((frame.size.width-20)/2, (frame.size.height-20)/2, 20, 20);
    }
    else
        activityIndicator.frame  = CGRectMake(titleLabel.frame.origin.x - 30 ,(frame.size.height- 20)/2, 20.0f, 20.0f);
    
    [view addSubview:titleLabel];
    [view addSubview:activityIndicator];
    
    
    titleLabel.backgroundColor        = [UIColor clearColor];
    view.backgroundColor              = [UIColor clearColor];
    activityIndicator.backgroundColor = [UIColor clearColor];
    return view;
}

+ (UIView*)errorFooterView:(CGRect)frame Text:(NSString*)text
{
    UILabel* titleLabel = [[UILabel alloc ] initWithFrame:frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = text;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor =  [UIColor grayColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    return titleLabel;
}


@end
