//
//  VZHTTPListModel.m
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZHTTPListModel.h"

@interface VZHTTPListModel()



@end

@implementation VZHTTPListModel


////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - getters

- (NSMutableArray* )objects
{
    if (!_objects) {
        _objects = [NSMutableArray new];
    }
    return _objects;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public methods

- (void)loadMore
{
    if (self.hasMore) {
        self.currentPageIndex += 1;
        [self loadInternal];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - @override methods - VZModel

- (void)reset
{
    self.currentPageIndex = 0;
    [self.objects removeAllObjects];
    [super reset];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - @override methods - VZHTTPModel


- (BOOL)parseResponse:(id)JSON
{
    if (![super parseResponse:JSON]) {
        return NO;
    }
    else
    {
        NSArray* list = [self responseObjects:JSON];
   
        if (self.pageMode == VZPageModePageDefault) {
            _hasMore = list.count > 0;
            
        }
        else if (self.pageMode == VZPageModePageReturnCount){
            _hasMore = list.count == self.pageSize;
        }
        else{
            _hasMore = self.pageSize*self.currentPageIndex >= self.totalCount;
        }
        
        if (list.count > 0) {
            [self.objects addObjectsFromArray:list];
            
        }
        return YES;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - protocol methods

- (NSMutableArray* )responseObjects:(id)JSON
{
    return nil;
}


@end
