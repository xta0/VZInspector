  
//
//  VLLineListModel.m
//  VZListExample
//
//  Created by Jayson on 2014-12-07 16:10:56 +0800.
//  Copyright (c) 2014年 VizLab: http://vizlab.com. All rights reserved.
//



#import "VLLineListModel.h"
#import "VLLineListItem.h"


@interface VLLineListModel()

@end

@implementation VLLineListModel

////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - @override methods

- (NSDictionary *)dataParams {
    
    //todo:
    
    return nil;
}

- (NSDictionary* )headerParams{
   
    //todo:
    
    return nil;
}


- (NSString *)methodName {
    
    //todo:
    return @"http://106.186.20.246:3000/statuses.json";
}

- (NSMutableArray* )responseObjects:(id)JSON
{
  
    //todo:
    NSMutableArray* ret = [NSMutableArray new];
    for (NSDictionary* dict in JSON) {
        
        VLLineListItem* item = [VLLineListItem new];
        [item autoKVCBinding:dict];
        
        
        NSString* content = item.content;
        CGSize sz = [content sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake([UIApplication sharedApplication].keyWindow.bounds.size.width-20, NSIntegerMax)];
        item.itemHeight = sz.height + 20;
        
        [ret addObject:item];
    }

    return ret;
}

@end

