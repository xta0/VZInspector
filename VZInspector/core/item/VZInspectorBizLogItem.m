//
//  VZInspectorBizLogItem.m
//  APInspector
//
//  Created by 净枫 on 16/6/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorBizLogItem.h"

@implementation VZInspectorBizLogItem

- (void)encodeWithCoder:(NSCoder *)aCoder{

    [aCoder encodeObject:self.indexPath     forKey:@"indexPath"];
    [aCoder encodeObject:@(self.itemHeight) forKey:@"itemHeight"];
    [aCoder encodeObject:self.cellClass forKey:@"cellClass"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self){
        
        self.indexPath = [aDecoder decodeObjectForKey:@"indexPath"];
        self.itemHeight = ((NSNumber*)[aDecoder decodeObjectForKey:@"itemHeight"]).floatValue;
        self.cellClass = [aDecoder decodeObjectForKey:@"cellClass"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    VZInspectorBizLogItem* item  = [[self class] allocWithZone:zone];
    item.indexPath = self.indexPath;
    item.itemHeight = self.itemHeight;
    item.cellClass = self.cellClass;
    return item;
}


@end
