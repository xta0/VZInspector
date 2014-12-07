//
//  VZInspectorHeapView.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-27.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import "VZInspectorHeapView.h"
#import "VZHeapInspector.h"

@interface VZInspectorHeapView()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UILabel* textLabel;
@property(nonatomic,strong)UIButton* backBtn;
@property(nonatomic,strong)UIButton* heapShotBtn;
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)NSArray* items;

@end

@implementation VZInspectorHeapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.textLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, frame.size.width-80, 44)];
        self.textLabel.text = @"Heap Shot";
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:18.0f];
        [self addSubview:self.textLabel];
        
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
        
        self.heapShotBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-20-44, 0, 44, 44)];
        self.heapShotBtn.backgroundColor = [UIColor clearColor];
        [self.heapShotBtn setTitle:@"Shot!" forState:UIControlStateNormal];
        [self.heapShotBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.heapShotBtn addTarget:self action:@selector(onHeapShot) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.heapShotBtn];
        
        self.backgroundColor = [UIColor clearColor];
        
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
    self.items = [[VZHeapInspector livingObjectsWithClassPrefix:[VZHeapInspector classPrefixName]] allObjects];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* sandCellId = @"heapIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:sandCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sandCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = self.items[indexPath.row];
    cell.tag = indexPath.row;
    
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
@end
