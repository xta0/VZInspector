//
//  VZListViewDataSource.m
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZListViewDataSource.h"
#import "VZListViewDelegate.h"
#import "VZListViewController.h"
#import "VZListCell.h"
#import "VZListItem.h"
#import "VZListDefaultLoadingCell.h"
#import "VZListDefaultErrorCell.h"
#import "VZListDefaultTextCell.h"
#import "VZHTTPListModel.h"

@interface VZListViewDataSource()
{
    //CFMutableDictionaryRef _modelMap;
    NSMutableDictionary* _itemsForSectionInternal;
    NSMutableDictionary* _totalCountForSectionInternal;
    
}

@end

@implementation VZListViewDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - setters



///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - getters

- (NSDictionary*)itemsForSection
{
    return [_itemsForSectionInternal copy];
}

- (NSDictionary*)totalCountForSection
{
    return [_totalCountForSectionInternal copy];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    self = [super init];
    
    if (self) {
        _itemsForSectionInternal      = [NSMutableDictionary new];
        _totalCountForSectionInternal = [NSMutableDictionary new];
    }
    return self;
}
- (void)dealloc
{
    _controller = nil;
    [_itemsForSectionInternal removeAllObjects];
    _itemsForSectionInternal = nil;
    
    [_totalCountForSectionInternal removeAllObjects];
    _totalCountForSectionInternal = nil;
    NSLog(@"[%@]--->dealloc",self.class);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public

- (void)setItems:(NSArray*)items ForSection:(NSInteger)n
{
    if(n>=0) {
        if (![items isKindOfClass:[NSMutableArray class]]) {
            [_itemsForSectionInternal setObject:[NSMutableArray arrayWithArray:items] forKey:@(n)];
        }
        else {
            [_itemsForSectionInternal setObject:items forKey:@(n)];
        }
    }
}

- (BOOL)removeItem:(VZListItem*)object FromSection:(NSInteger)n {
    if (n >= 0 && n < _itemsForSectionInternal.count) {
        NSMutableArray *array = [_itemsForSectionInternal objectForKey:@(n)];
        for (id anyobject in array) {
            if (anyobject == object) {
                [array removeObject:anyobject];
                return YES;
            }
        }
    }
    return NO;
}

- (NSArray *)ItemsForSection:(int)section {
    if (section < [_itemsForSectionInternal count]) {
        return _itemsForSectionInternal[@(section)];
    }
    return nil;
}

- (void)removeItemsFromSection:(NSInteger)n
{
    if (n>=0) {
        [_itemsForSectionInternal removeObjectForKey:@(n)];
    }
}
- (void)removeAllItems
{
    [_itemsForSectionInternal removeAllObjects];
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableView's dataSource

//子类重载
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* items = _itemsForSectionInternal[@(section)];
    return items.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}
- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"";
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.controller tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //拿到当前的item
    VZListItem *item = [self itemForCellAtIndexPath:indexPath];
    //拿到当前cell的类型
    Class cellClass = [self cellClassForItem:item AtIndex:indexPath];
    //拿到name
    NSString* identifier = NSStringFromClass(cellClass);
    //创建cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //绑定cell和item
    if ([cell isKindOfClass:[VZListCell class]])
    {
        VZListCell* customCell = (VZListCell*)cell;
        customCell.indexPath = indexPath;
        customCell.delegate  = (id<VZListCellDelegate>)tableView.delegate;
        
        if (item)
        {
            //为cell,item绑定index
            item.indexPath = indexPath;
            [(VZListCell *)cell setItem:item];
        }
        else
        {
            //Jayson:
            /**
             *  @dicussion:
             *
             *  These codes are never supposed to be executed.
             *  If it does, it probably means something goes wrong.
             *  For some unpredictable error we display an empty cell with 44 pixel height
             */
            
            VZListItem* item = [VZListItem new];
            item.itemType = kItem_Normal;
            item.itemHeight = 44;
            item.indexPath = indexPath;
            [(VZListCell *)cell setItem:item];
        }
    }
    
    
    
    return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - private

- (UITableViewCell*)tableView:(UITableView *)tableView initCellAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

// item for index
- (VZListItem*)itemForCellAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray* items = _itemsForSectionInternal[@(indexPath.section)];
    
    VZListItem* item = nil;
    
    if (indexPath.row < items.count) {
        
        item = items[indexPath.row];
    }
    else
    {
        item = [VZListItem new];
    }
    return item;
    
}
// cell for index
- (Class)cellClassForItem:(VZListItem*)item AtIndex:(NSIndexPath *)indexPath
{
    if (item.itemType == kItem_Normal) {
        return [VZListCell class];
    }
    else if (item.itemType == kItem_Loading) {
        return [VZListDefaultLoadingCell class];
    }
    else if (item.itemType == kItem_Error)
    {
        return [VZListDefaultErrorCell class];
    }
    else if (item.itemType == kItem_Customize)
    {
        return [VZListDefaultTextCell class];
    }
    else
        return [VZListCell class];
}
// bind model
- (void)tableViewControllerDidLoadModel:(VZHTTPListModel*)model ForSection:(NSInteger)section
{
    
    // set totoal count
    [_totalCountForSectionInternal setObject:@(model.totalCount) forKey:@(section)];
    
    // set data
    NSMutableArray* items = [model.objects mutableCopy];
    [self setItems:items ForSection:section];
    
}


@end
