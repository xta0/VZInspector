//
//  VZListDefaultLoadingCell.m
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZListDefaultLoadingCell.h"
#import "VZListDefaultTextItem.h"

@implementation VZListDefaultLoadingCell
{
    UIActivityIndicatorView* _indicator;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        CGRect frame = self.contentView.frame;
        
        _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((CGRectGetWidth(frame)-20)/2, (CGRectGetHeight(frame)-20)/2, 20, 20)];
        _indicator.color = [UIColor redColor];
        [_indicator stopAnimating];
        
        [self.contentView addSubview:_indicator];
        
    }
    return self;
}
- (void)setItem:(VZListItem *)item
{
    [super setItem:item];
    
    if ([item isKindOfClass:[VZListDefaultTextItem class]]) {
        [_indicator startAnimating];
    }
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame;
    _indicator.hidden = NO;
    _indicator.frame = CGRectMake((CGRectGetWidth(frame)-20)/2, (CGRectGetHeight(frame)-20)/2, 20, 20);
    
}
@end
