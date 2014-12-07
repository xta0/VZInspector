  
//
//  VZLineListViewDataSource.m
//  VZInspector
//
//  Created by Jayson on 2014-12-07 15:16:33 +0800.
//  Copyright (c) 2014年 http://akadealloc.github.io/blog. All rights reserved.
//



#import "VZLineListViewDataSource.h"
#import "VZLineListCell.h"

@interface VZLineListViewDataSource()

@end

@implementation VZLineListViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    //default:
    return 1; 

}

- (Class)cellClassForItem:(id)item AtIndex:(NSIndexPath *)indexPath{

    //@REQUIRED:
    
    return [VZLineListCell class];
    

}

//@optional:
//- (TBCitySBTableViewItem*)itemForCellAtIndexPath:(NSIndexPath*)indexPath{

    //default:
    //return [super itemForCellAtIndexPath:indexPath]; 

//}


@end  
