//
//  VZInspectorHeapView.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-27.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//
#include <QuartzCore/QuartzCore.h>
#import "VZInspectorHeapView.h"
#import "VZHeapInspector.h"

@interface VZInspectorHeapView()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property(nonatomic,strong)UITextField* searchBar;
@property(nonatomic,strong)UILabel* textLabel;
@property(nonatomic,strong)UIButton* backBtn;
@property(nonatomic,strong)UIButton* heapShotBtn;
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)NSArray* items;
@property(nonatomic,strong)NSArray* filterItems;

@end

@implementation VZInspectorHeapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
         self.backgroundColor = [UIColor clearColor];
        

        CGRect rect = CGRectMake(0, 0, frame.size.width, 44);
        self.searchBar = [[UITextField alloc]initWithFrame:CGRectInset(rect, 80, 5)];
        self.searchBar.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        self.searchBar.clearButtonMode = UITextFieldViewModeAlways;
        self.searchBar.borderStyle = UITextBorderStyleRoundedRect;
        self.searchBar.clearButtonMode = UITextFieldViewModeAlways;
        self.searchBar.textColor = [UIColor orangeColor];
        self.searchBar.delegate = self;
        [self.searchBar addTarget:self action:@selector(textFieldDidChangeCharacter:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:self.searchBar];
        
        self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 44, 44)];
        self.backBtn.backgroundColor = [UIColor clearColor];
        [self.backBtn setTitle:@"<-" forState:UIControlStateNormal];
        [self.backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.backBtn addTarget:self.parentViewController action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
        [self addSubview:self.backBtn];
        
        self.heapShotBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-10-44, 0, 44, 44)];
        self.heapShotBtn.backgroundColor = [UIColor clearColor];
        [self.heapShotBtn setTitle:@"Shot" forState:UIControlStateNormal];
        [self.heapShotBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.heapShotBtn addTarget:self action:@selector(onHeapShot) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.heapShotBtn];
        
  
    
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,44, frame.size.width, frame.size.height-44)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate   = self;
        self.tableView.dataSource = self;
        self.tableView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        self.tableView.layer.borderWidth = 2.0f;
        [self addSubview:self.tableView];

    
      //  [self heapShot];
    }
    return self;
}

- (void)heapShot
{
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    
    self.items = [[VZHeapInspector livingObjectsWithClassPrefix:[VZHeapInspector classPrefixName]] allObjects];
    [self.tableView reloadData];
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
    }
    
    if (self.searchBar.text.length > 0) {
        cell.textLabel.text = self.filterItems[indexPath.row];
    }
    else
        cell.textLabel.text = self.items[indexPath.row];
   
    cell.tag = indexPath.row;
    [cell.textLabel sizeToFit];
    
    return cell;
}

- (void)onClose
{
    UIButton* btn = [UIButton new];
    btn.tag = 11;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onBack) withObject:btn];
#pragma clang diagnostic pop
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
        
        self.filterItems = [[tmpList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString*  evaluatedObject, NSDictionary *bindings) {
            
            return [evaluatedObject hasPrefix:text];
            
        }]] copy];
    }
    else
    {
        [self.searchBar resignFirstResponder];
    }

    
    [self.tableView reloadData];

}


@end
