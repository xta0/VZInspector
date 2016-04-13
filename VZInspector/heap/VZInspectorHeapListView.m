//
//  VZInspectorHeapView.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-27.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//
#include <QuartzCore/QuartzCore.h>
#import "VZInspectorHeapListView.h"
#import "VZHeapInspector.h"

@interface VZInspectorHeapListView()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property(nonatomic,strong)UIActivityIndicatorView* indicator;
@property(nonatomic,strong)UITextField* searchBar;
@property(nonatomic,strong)UILabel* textLabel;
@property(nonatomic,strong)UIButton* backBtn;
@property(nonatomic,strong)UIButton* heapShotBtn;
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)NSArray* items;
@property(nonatomic,strong)NSArray* filterItems;

@end

@implementation VZInspectorHeapListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        
         self.backgroundColor = [UIColor clearColor];
        

        CGRect rect = CGRectMake(0, 0, frame.size.width - 64, 44);
        self.searchBar = [[UITextField alloc]initWithFrame:CGRectInset(rect, 10, 7)];
        self.searchBar.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        self.searchBar.clearButtonMode = UITextFieldViewModeAlways;
        self.searchBar.borderStyle = UITextBorderStyleRoundedRect;
        self.searchBar.clearButtonMode = UITextFieldViewModeAlways;
        self.searchBar.textColor = [UIColor orangeColor];
        self.searchBar.delegate = self;
        self.searchBar.layer.borderColor = [UIColor orangeColor].CGColor;
        self.searchBar.layer.borderWidth = 1.0f;
        self.searchBar.layer.masksToBounds = true;
        self.searchBar.layer.cornerRadius = 4.0f;
        [self.searchBar addTarget:self action:@selector(textFieldDidChangeCharacter:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:self.searchBar];

        self.heapShotBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-10-44, 0, 44, 44)];
        self.heapShotBtn.backgroundColor = [UIColor clearColor];
        [self.heapShotBtn setTitle:@"Shot" forState:UIControlStateNormal];
        [self.heapShotBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.heapShotBtn addTarget:self action:@selector(onHeapShot) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.heapShotBtn];
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,44, frame.size.width, frame.size.height-44)];
        self.tableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        self.tableView.delegate   = self;
        self.tableView.dataSource = self;
        self.tableView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        self.tableView.layer.borderWidth = 2.0f;
        [self addSubview:self.tableView];
        
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.color = [UIColor grayColor];
        _indicator.frame = CGRectMake((self.tableView.frame.size.width-20)/2, (self.tableView.frame.size.height - 20)/2, 20, 20);
        _indicator.hidesWhenStopped=true;
        [self addSubview:_indicator];
        
        self.title = @"Alived Objects on Heap";
        
        [self heapShot];
    }
    return self;
}

- (void)heapShot
{
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    
    [self.indicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.items = [[VZHeapInspector livingObjectsWithClassPrefix:[VZHeapInspector classPrefixName]] allObjects];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.indicator stopAnimating];
            [self.tableView reloadData];
        });
        
    });

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchBar.text.length > 0) {
        return self.filterItems.count;
    }
    else
        return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* sandCellId = @"heapIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:sandCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sandCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onCellTapped:)]];
    }
    
    
    id obj = nil;
    if (self.searchBar.text.length > 0) {
        obj = self.filterItems[indexPath.row];
    }
    else
    {
        obj = self.items[indexPath.row];
    }
    NSString *string = [NSString stringWithFormat:@"%@: %p",[obj class],obj];
    cell.textLabel.text = string;
   
    cell.tag = indexPath.row;
    [cell.textLabel sizeToFit];
    
    return cell;
}


- (void)onCellTapped:(UIGestureRecognizer* )reg
{
    UIView* cell = reg.view;
    
    
    NSArray* items = nil;
    
    if (self.searchBar.text.length > 0) {
        items = self.filterItems;
    }
    else{
        items = self.items;
    }
    
    id obj = items[cell.tag];
    
    [self.delegate performSelector:@selector(push:object:) withObject:@"VZInspectorHeapObjectView" withObject:obj];

}

- (void)onHeapShot
{
    [self heapShot];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.searchBar resignFirstResponder];
    return true;
}


- (void)textFieldDidChangeCharacter:(id)sender
{
    
    NSString* text = self.searchBar.text;
 
    if (text.length > 0) {
     
        NSArray* tmpList =  [self.items copy];
        
        self.filterItems = [[tmpList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  obj, NSDictionary *bindings) {
            
            NSString *string = [NSString stringWithFormat:@"%@",[obj class]];
            return [string hasPrefix:text];
            
        }]] copy];
    }
    else
    {
        [self.searchBar resignFirstResponder];
    }

    
    [self.tableView reloadData];

}


@end
