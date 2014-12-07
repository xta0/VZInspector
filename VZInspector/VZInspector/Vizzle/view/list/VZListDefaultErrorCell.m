//
//  VZListDefaultErrorCell.m
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZListDefaultErrorCell.h"
#import "VZListDefaultTextItem.h"


@implementation VZListDefaultErrorCell
{
    UILabel* _label;
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _label = [[UILabel alloc]initWithFrame:self.contentView.bounds];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor grayColor];
        _label.font = [UIFont systemFontOfSize:16.0f];
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label];
        
        
    }
    return self;
}

- (void)setItem:(VZListItem *)item
{
    [super setItem:item];
    
    if ([item isKindOfClass:[VZListDefaultTextItem class]]) {
        _label.text = ((VZListDefaultTextItem*)item).text;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _label.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}
@end
