//
//  VZListItem.m
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZListItem.h"

@implementation VZListItem

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.indexPath     forKey:@"indexPath"];
    [aCoder encodeObject:@(self.itemHeight) forKey:@"itemHeight"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self)
    {
        self.indexPath = [aDecoder decodeObjectForKey:@"indexPath"];
        self.itemHeight = ((NSNumber*)[aDecoder decodeObjectForKey:@"itemHeight"]).floatValue;
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"[%@]-->dealloc",self.class);
}

@end
