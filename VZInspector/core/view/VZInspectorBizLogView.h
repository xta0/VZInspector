//
//  VZInspectorLogView.h
//  APInspector
//
//  Created by 净枫 on 16/6/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZInspectorBizLogItem.h"
#import "VZInspectorBizLogToolBarItem.h"
#import "VZInspectorTagListView.h"
#import "VZInspectorSearchBar.h"

@protocol VZInspectorBizLogViewDelegate <NSObject>

@optional
- (void)onClickCancleButton;
- (void)onClickClearButton;

@end

@interface VZInspectorBizLogView : UIView<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic , weak) id<VZInspectorBizLogViewDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UILabel *dragView;

@property (nonatomic, strong) VZInspectorSearchBar *searchView;

@property (nonatomic, strong) VZInspectorTagListView *tagListView;

@property (nonatomic, strong) UIView *searchBarBackgroundView;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *leftButtonTitle;

@property (nonatomic, strong) NSString *rightButtonTitle;

@property (nonatomic, assign) BOOL hasSearchBar;

@property (nonatomic,strong) NSArray<VZInspectorBizLogToolBarItem *> *toolBarItems;

@property (nonatomic, strong)VZInspectorTagViewTap tagViewTapListener;

- (void)reloadDatas;

- (void)setToolBarHidden:(BOOL)hidden;

- (VZInspectorBizLogItem *)itemForCellAtIndexPath:(NSIndexPath *)indexPath;

- (void)addDragTagGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer;

-(void)textFieldTextDidChange:(UITextField *)textField;

- (void)leftButtonClick;

- (void)rightButtonClick;

@end
