//
//  VZInspectorNetworkHistoryView.m
//  VZInspector
//
//  Created by moxin on 15/4/15.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZInspectorNetworkHistoryView.h"
#import "VZInspectorNetworkDetailView.h"
#import "VZNetworkRecorder.h"
#import "VZNetworkTransaction.h"
#import "VZInspectorUtility.h"
#import "VZNetworkInspector.h"

static double kHeaderHeight = 44.0;

@interface VZInspectorNetworkHistoryView()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,VZInspectorNetworkDetailView>

@property(nonatomic,strong)UITextField* searchBar;
@property(nonatomic,strong)UILabel* textLabel;
@property(nonatomic,strong)UIButton* backBtn;
@property(nonatomic,strong)UIButton* refreshBtn;
@property(nonatomic,strong)UIButton* clearBtn;
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)NSArray* items;
@property(nonatomic,strong)NSArray* filterItems;
@property(nonatomic,strong)VZInspectorNetworkDetailView* detailView;

@end

@implementation VZInspectorNetworkHistoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        CGRect rect = CGRectMake(0, 0, frame.size.width, kHeaderHeight);
        
        UIView* headerView = [[UIView alloc]initWithFrame:rect];
        headerView.backgroundColor = [UIColor clearColor];
        
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 43, frame.size.width, 1)];
        line.backgroundColor = [UIColor orangeColor];
        [headerView addSubview:line];
        
        
        self.searchBar = [[UITextField alloc]initWithFrame:CGRectInset(rect, 80, 7)];
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
        [headerView addSubview:self.searchBar];
        
        self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 44, 44)];
        self.backBtn.backgroundColor = [UIColor clearColor];
        [self.backBtn setTitle:@"<-" forState:UIControlStateNormal];
        [self.backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.backBtn addTarget:self.parentViewController action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
        [headerView addSubview:self.backBtn];
        
        
        self.clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 10 - 60, 7, 30, 30)];
        self.clearBtn.layer.cornerRadius = 15.0f;
        self.clearBtn.layer.masksToBounds = true;
        [self.clearBtn setTitle:@"C" forState:UIControlStateNormal];
        [self.clearBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.clearBtn addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:self.clearBtn];
        
        self.refreshBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-10-30, 7, 30, 30)];
        self.refreshBtn.layer.cornerRadius = 15.0f;
        self.refreshBtn.layer.masksToBounds = true;
        [self.refreshBtn setTitle:@"R" forState:UIControlStateNormal];
        [self.refreshBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.refreshBtn addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:self.refreshBtn];
        
    
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,headerView.frame.size.height, frame.size.width, frame.size.height - headerView.frame.size.height)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate   = self;
        self.tableView.dataSource = self;
//        self.tableView.tableHeaderView = headerView;

        [self addSubview:headerView];
//        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:headerView.frame];
        [self addSubview:self.tableView];
        
        self.detailView = [[VZInspectorNetworkDetailView alloc]initWithFrame:CGRectMake(CGRectGetWidth(rect), 0, frame.size.width, frame.size.height)];
        self.detailView.delegate = self;
        [self addSubview:self.detailView];
        
        [self onRefresh];
    }
    return self;
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
    return 60;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* network_identifier = @"network_identifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:network_identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:network_identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.detailTextLabel.textColor = [UIColor orangeColor];
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSelfClicked:)]];
    }
    
    VZNetworkTransaction* transaction = nil;
    if (self.searchBar.text.length > 0) {

        transaction = self.filterItems[indexPath.row];
    }
    else
    {
        transaction = self.items[indexPath.row];
    }
    
    cell.textLabel.text         = [self urlString:transaction];
    cell.detailTextLabel.text   = [self detailString:transaction];
    
    
    cell.tag = indexPath.row;
    [cell.textLabel sizeToFit];
    [cell.detailTextLabel sizeToFit];
    
    return cell;
}

- (void)onSelfClicked:(UITapGestureRecognizer* )sender
{
    NSInteger index = sender.view.tag;
    
    VZNetworkTransaction* transction =  nil;
    
    if (self.searchBar.text.length > 0) {
        
        transction = self.filterItems[index];
    }
    else
        transction = self.items[index];
    
    self.detailView.transaction = transction;
    
    [self pushDetailView];
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

- (void)onRefresh
{
    self.items = [[VZNetworkRecorder defaultRecorder] networkTransactions];
    [self.tableView reloadData];
}

- (void)onClear{
    
    self.items = @[];
    [[VZNetworkRecorder defaultRecorder] clearRecordedActivity];
    [self.tableView reloadData];
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
        
        self.filterItems = [[tmpList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(VZNetworkTransaction*  evaluatedObject, NSDictionary *bindings) {
            
            return [[self urlString:evaluatedObject] hasPrefix:text];
            
        }]] copy];
    }
    else
    {
        [self.searchBar resignFirstResponder];
    }
    
    
    [self.tableView reloadData];
    
}

- (NSString* )urlString:(VZNetworkTransaction* )transaction
{
    NSURL *url = transaction.request.URL;
    for (TransactionTitleFilter filter in [VZNetworkInspector sharedInstance].transactionTitleFilters) {
        NSString *title = filter(transaction);
        if (title.length > 0) {
            return title;
        }
    }
    
    NSMutableArray *mutablePathComponents = [[url pathComponents] mutableCopy];
    NSString *path = [url host];
    for (NSString *pathComponent in mutablePathComponents) {
        path = [path stringByAppendingPathComponent:pathComponent];
    }
    return path;
}

- (NSString* )detailString:(VZNetworkTransaction* )transaction
{
    NSMutableArray *detailComponents = [NSMutableArray array];
    
    NSString *timestamp = [VZInspectorUtility timestampStringFromRequestDate:transaction.startTime];
    [detailComponents addObject:timestamp];
    
    // Omit method for GET (assumed as default)
    NSString *httpMethod = transaction.request.HTTPMethod;
    if (httpMethod) {
        [detailComponents addObject:httpMethod];
    }
    
    if (transaction.transactionState == VZNetworkTransactionStateFinished || transaction.transactionState == VZNetworkTransactionStateFailed) {
        NSString *statusCodeString = [VZInspectorUtility statusCodeStringFromURLResponse:transaction.response];
        if ([statusCodeString length] > 0) {
            [detailComponents addObject:statusCodeString];
        }
        
        if (transaction.receivedDataLength > 0) {
            NSString *responseSize = [NSByteCountFormatter stringFromByteCount:transaction.receivedDataLength countStyle:NSByteCountFormatterCountStyleBinary];
            [detailComponents addObject:responseSize];
        }
        
        NSString *totalDuration = [VZInspectorUtility stringFromRequestDuration:transaction.duration];
        NSString *latency = [VZInspectorUtility stringFromRequestDuration:transaction.latency];
        NSString *duration = [NSString stringWithFormat:@"%@ (%@)", totalDuration, latency];
        [detailComponents addObject:duration];
    } else {

    }
    
    return [detailComponents componentsJoinedByString:@" ・ "];
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)onDetailBack
{
    [self popDetailView];
}

- (void)pushDetailView
{
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.tableView.frame;
        frame.origin.x = - frame.size.width;
        self.tableView.frame = frame;
        self.detailView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
    }];
}

- (void)popDetailView
{
    [UIView animateWithDuration:0.4 animations:^{
        
        CGRect frame = self.tableView.frame;
        frame.origin.x = 0;
        self.tableView.frame = frame;
        self.detailView.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
        
    }];

}



@end
