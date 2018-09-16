//
//  ViewController.m
//  VZInspectorDemo
//
//  Created by moxin on 9/11/18.
//  Copyright © 2018 Tao Xu. All rights reserved.
//

#import "ViewController.h"
#include <memory>

@interface ViewController()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) id list;
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NSMutableArray* items;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Inspector Demo"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(load)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(memoryPeek)];
    
    self.items = [NSMutableArray new];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-64)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self load];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"vzinspectordemo";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    NSDictionary* info = self.items[indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = info[@"title"];
    [cell.textLabel sizeToFit];
    
    cell.detailTextLabel.text = info[@"body"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    cell.detailTextLabel.numberOfLines = 0;
    [cell.detailTextLabel sizeToFit];
    
    return cell;
    
}

- (void)load
{
    [self.items removeAllObjects];
    [self.tableView reloadData];
    self.tableView.tableFooterView = [self loadingFooterView];
    
    NSString* url = @"https://jsonplaceholder.typicode.com/posts/";
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if(data){
        
            NSDictionary* JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSLog(@"%@",JSON);
            
            for (NSDictionary* dict in JSON) {
                [self.items addObject:dict];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.tableView.tableFooterView = nil;
                [self.tableView reloadData];
                
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self alert:@"Error"];
                self.tableView.tableFooterView = nil;
            });
        }
        
        
    }] resume];
    
}

- (void)memoryPeek
{
    static int* _ptr = nullptr;
    static std::allocator<int> _allocator;
//    static std::allocator<int>::size_type sz_4gb = 1024*1024*1024*sizeof(int); //this will trigger memory warning
    static std::allocator<int>::size_type sz_400mb = 1024*1024*sizeof(int);
    
    if(_ptr){
        _allocator.deallocate(_ptr, sz_400mb);
        _ptr = nullptr;
        [self alert:@"Clear"];
    }else{

        //alloc 4GB memory
        _ptr = _allocator.allocate(sz_400mb);
        _allocator.construct(_ptr, 0);
        [self alert:@"Alloc 500MB memory"];
    }
}
#pragma mark - private method

- (void)alert:(NSString*) title{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}


- (UIView* )loadingFooterView
{
    UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds)-20)/2, 11, 20, 20)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [indicator startAnimating];
    [v addSubview:indicator];
    
    return v;
}


@end
