  
//
//  VLLineListCell.m
//  VZListExample
//
//  Created by Jayson on 2014-12-07 16:10:56 +0800.
//  Copyright (c) 2014年 VizLab: http://vizlab.com. All rights reserved.
//



#import "VLLineListCell.h"
#import "VLLineListItem.h"

@interface VLLineListCell()

@property(nonatomic,strong) UILabel* contentLabel;

@end

@implementation VLLineListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //todo: add some UI code
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.font = [UIFont systemFontOfSize:14.0f];
        self.contentLabel.textColor = [UIColor blackColor];
        self.contentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.contentLabel];
        
    }
    return self;
}

- (void)setItem:(VLLineListItem *)item
{
    [super setItem:item];
    
    self.contentLabel.text = item.content;
  
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.contentLabel.frame = CGRectZero;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentLabel.frame = CGRectInset(self.bounds, 10, 10);
  
  
}
@end
  
