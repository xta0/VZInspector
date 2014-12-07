  
//
//  VLLineListViewController.m
//  VZListExample
//
//  Created by Jayson on 2014-12-07 16:10:56 +0800.
//  Copyright (c) 2014年 VizLab: http://vizlab.com. All rights reserved.
//



#import "VLLineListViewController.h"
#import "VLLineLogic.h"
#import "VLLineListModel.h"
#import "VLLineListViewDataSource.h"
#import "VLLineListViewDelegate.h"



@interface VLLineListViewController()

 
@property(nonatomic,strong)VLLineListModel *lineListModel;
@property(nonatomic,strong)VLLineLogic *lineLogic;
@property(nonatomic,strong)VLLineListViewDataSource* ds;
@property(nonatomic,strong)VLLineListViewDelegate* dl;

@end

@implementation VLLineListViewController

//////////////////////////////////////////////////////////// 
#pragma mark - setters 



//////////////////////////////////////////////////////////// 
#pragma mark - getters 

   
- (VLLineListModel *)lineListModel
{
    if (!_lineListModel) {
        _lineListModel = [VLLineListModel new];
        _lineListModel.requestType = VZModelAFNetworking;
        _lineListModel.key = @"__VLLineListModel__";
    }
    return _lineListModel;
}

- (VLLineLogic *)lineLogic
{
    if(!_lineLogic){
        _lineLogic = [VLLineLogic new];
    }

    return _lineLogic;
}

- (VLLineListViewDelegate* )dl
{
    if (!_dl) {
        _dl = [VLLineListViewDelegate new];
    }
    return _dl;
}

- (VLLineListViewDataSource* )ds
{
    if (!_ds) {
        _ds = [VLLineListViewDataSource new];
    }
    return _ds;
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark - life cycle methods

- (id)init
{
    self = [super init];
    
    if (self) {
      
        self.logic = self.lineLogic;
      
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"VizLine";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //1,config your tableview
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.separatorStyle = YES;
    
    //2,set some properties:下拉刷新，自动翻页
    self.bNeedLoadMore = NO;
    self.bNeedPullRefresh = YES;

    self.dataSource = self.ds;
    self.delegate = self.dl;

    //4,@REQUIRED:YOU MUST SET A KEY MODEL!
    self.keyModel = self.lineListModel;
    
    //5,REQUIRED:register model to parent view controller
    [self registerModel:self.keyModel];

    //6,Load Data
    [self load];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //todo..
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //todo..
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //todo..
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //todo..
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc {
    
    //todo..
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - @override methods - VZViewController


////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - @override methods - VZListViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  //todo...
  
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath component:(NSDictionary *)bundle{

  //todo:... 

}

//////////////////////////////////////////////////////////// 
#pragma mark - public method 



//////////////////////////////////////////////////////////// 
#pragma mark - private callback method 



@end
 
