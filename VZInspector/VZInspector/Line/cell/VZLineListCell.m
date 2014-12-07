  
//
//  VZLineListCell.m
//  VZInspector
//
//  Created by Jayson on 2014-12-07 15:16:33 +0800.
//  Copyright (c) 2014年 http://akadealloc.github.io/blog. All rights reserved.
//



#import "VZLineListCell.h"
#import "VZLineListItem.h"

@interface VZLineListCell()

@end

@implementation VZLineListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //todo: add some UI code
    
        
    }
    return self;
}

+ (CGFloat) tableView:(UITableView *)tableView variantRowHeightForItem:(id)item AtIndex:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)setItem:(VZLineListItem *)item
{
    [super setItem:item];
  
}

- (void)layoutSubviews
{
    [super layoutSubviews];
  
  
}
@end
  
