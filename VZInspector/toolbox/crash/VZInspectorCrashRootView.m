//
//  VZInspectorCrashRootView.m
//  VZInspector
//
//  Created by moxin.xt on 14-12-12.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspectorCrashRootView.h"
#import "VZInspectorCrashView.h"
#import "VZCrashInspector.h"


@interface VZInspectorCrashRootHeaderView : UIView

@property(nonatomic,strong) UILabel* textLabel;
@property(nonatomic,strong) UIButton* backBtn;
@property(nonatomic,weak) id delegate;

@end

@implementation VZInspectorCrashRootHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 13, frame.size.width, 18)];
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
        [self.backBtn addTarget:self.delegate action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
        [self addSubview:self.backBtn];
    }
    return self;
}

@end

@interface VZInspectorCrashRootView()<UITableViewDataSource,UITableViewDelegate,VZInspectorCrashViewCallBackProtocol>

@property(nonatomic,strong)VZInspectorCrashRootHeaderView* headerView;
@property(nonatomic,strong)NSString* filename;
@property(nonatomic,strong)UIView* contentView;
@property(nonatomic,strong)UITableView* listView;
@property(nonatomic,strong)VZInspectorCrashView* subView;
@property(nonatomic,strong)NSArray* pathNames;


@end

@implementation VZInspectorCrashRootView

- (id)initWithFrame:(CGRect)frame parentViewController:(UIViewController *)controller
{
    self = [super initWithFrame:frame parentViewController:controller];
    
    if (self) {
        
        
        //contentview
        self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentView];
        
        
        //header view
        self.headerView = [[VZInspectorCrashRootHeaderView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        self.headerView.delegate = self;
        self.headerView.textLabel.text = @"All Crashes";
        [self.contentView addSubview:self.headerView];
        
        //list view
        self.listView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height-44)];
        self.listView.backgroundColor = [UIColor clearColor];
        self.listView.delegate = self;
        self.listView.dataSource = self;
        [self.contentView addSubview:self.listView];
        
        //load data
        self.pathNames = [VZCrashInspector sharedInstance].crashPlist;

        
        //add subview
        self.subView = [[VZInspectorCrashView alloc]initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        self.subView.delegate = self;
        [self addSubview:self.subView];
        
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pathNames.count;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* sandCellId = @"crashIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:sandCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sandCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSelfClicked:)]];
    }
    
    cell.textLabel.text = self.pathNames[indexPath.row];
    cell.tag = indexPath.row;
    
    
    return cell;
}


- (void)onSelfClicked:(UITapGestureRecognizer* )tap
{
    UIView* view = tap.view;
    NSInteger index = view.tag;
    
    if (index < self.pathNames.count) {
    
        NSString* path = self.pathNames[index];
        self.subView.path = path;

        [UIView animateWithDuration:0.4 animations:^{
            
            self.contentView.frame = CGRectMake(-CGRectGetWidth(self.bounds), 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            self.subView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            
        } completion:^(BOOL finished) {
            
        }];

    }
}

- (void)onBack {
    [UIView animateWithDuration:0.4 animations:^{
        
        self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.subView.frame = CGRectMake(CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        
        
    } completion:^(BOOL finished) {
        
        
    }];
}

@end


