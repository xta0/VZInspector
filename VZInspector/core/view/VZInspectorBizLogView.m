//
//  VZInspectorLogView.m
//  APInspector
//
//  Created by 净枫 on 16/6/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorBizLogView.h"
#import "VZInspectorBizLogItem.h"
#import "VZInspectorBizLogCell.h"
#import "VZInspectorTagListView.h"
#import "VZInspectorTagView.h"
#import "VZDefine.h"
#import "VZInspectorResource.h"

@interface VZInspectorBizLogView()

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIButton *clearButton;

@property (nonatomic, strong) UIView *toolBarLineView;

@property (nonatomic, assign) BOOL hasToolBar;

@property (nonatomic, assign) CGRect contentFrame;

@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation VZInspectorBizLogView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _contentFrame = frame;
        self.userInteractionEnabled = YES;
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        _headerView.backgroundColor = VZ_RGBA(0xffffff, 0.8);
        
        UIView* topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        topLine.backgroundColor = [UIColor orangeColor];
        [_headerView addSubview:topLine];
        
        
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 43, frame.size.width, 1)];
        line.backgroundColor = [UIColor orangeColor];
        [_headerView addSubview:line];
        [self addSubview:_headerView];
        
        _backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 50, 44)];
        _backButton.backgroundColor = [UIColor clearColor];
        [_backButton setTitle:@"Close" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [_backButton addTarget:self action:@selector(onCancle) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_backButton];
        
        _clearButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 10 - 44 , 0, 50, 44)];
        _clearButton.backgroundColor = [UIColor clearColor];
        [_clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        [_clearButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        _clearButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [_clearButton addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_clearButton];
        
        _dragView = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_backButton.frame) + 10, 0, CGRectGetMinX(_clearButton.frame) - CGRectGetMaxX(_backButton.frame) - 20, 44)];
        _dragView.backgroundColor = VZ_RGBA(0xA9A9A9, 0.5);
        _dragView.textColor = [UIColor whiteColor];
        _dragView.textAlignment = NSTextAlignmentCenter;
        _dragView.userInteractionEnabled = YES;
        _dragView.font = [UIFont systemFontOfSize:15];
        [_headerView addSubview:_dragView];
        
        [self addSubview:_headerView];
        
        _tagListView = [[VZInspectorTagListView alloc]initWithFrame:CGRectMake(0, 44, frame.size.width, 0)];
        [self addSubview:_tagListView];
        
        _toolBarLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, frame.size.width, 0)];
        _toolBarLineView.backgroundColor = VZ_RGBA(0xA9A9A9, 0.5);
        _toolBarLineView.hidden = YES;
        [self addSubview:_toolBarLineView];
        
        
        _searchBarBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, frame.size.width, 30)];
        _searchBarBackgroundView.backgroundColor = [UIColor whiteColor];
        _searchBarBackgroundView.layer.borderWidth = 0.5;
        _searchBarBackgroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self addSubview:_searchBarBackgroundView];
        
        _searchView = [[VZInspectorSearchBar alloc] initWithFrame:CGRectMake(5, 0, frame.size.width, 30)];
        _searchView.backgroundColor = [UIColor whiteColor];
        _searchView.font = [UIFont systemFontOfSize:13];
        _searchView.placeholder = @"filter...";
        _searchView.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchView.delegate = self;
        [_searchView addTarget:self
                             action:@selector(textFieldTextDidChange:)
                   forControlEvents:UIControlEventEditingChanged];

        
        UIImageView *searchIconView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
        searchIconView.image = [VZInspectorResource searchBarIcon];
        _searchView.leftView = searchIconView;
        _searchView.leftViewMode = UITextFieldViewModeAlways;
        
        _searchView.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);

        
        [_searchBarBackgroundView addSubview:_searchView];
        _searchBarBackgroundView.hidden = YES;
        _hasSearchBar = NO;
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,44 , frame.size.width, frame.size.height - 44)];
        self.tableView.backgroundColor = VZ_RGBA(0xffffff, 0.9);
        self.tableView.userInteractionEnabled = YES;
        self.tableView.scrollEnabled = YES;
        self.tableView.delegate   = self;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
        

        UIView* _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, kOnePix)];
        _bottomLine.backgroundColor = [UIColor orangeColor];
        _bottomLine.layer.zPosition = 1000;
        [self addSubview:_bottomLine];
        
        [self reloadDatas];
        
        
    }
    return self;
}

- (void)setToolBarItems:(NSArray<VZInspectorBizLogToolBarItem *> *)toolBarItems{
    if(_tagListView && toolBarItems.count > 0){
        [_tagListView addTagItems:toolBarItems];
        _hasToolBar = YES;
        [self resetAllView];
    }else{
        _hasToolBar = NO;
    }

}

- (void)setHasSearchBar:(BOOL)hasSearchBar{
    
    if(hasSearchBar == _hasSearchBar){
        return;
    }
    
    _hasSearchBar = hasSearchBar;
    
    [self resetAllView];

}

- (void)resetAllView{
    CGFloat searchBarHeight = 0;
    CGFloat toolBarHeight = 0;
    if(_hasSearchBar){
        searchBarHeight = _searchBarBackgroundView.frame.size.height;
    }else{
        searchBarHeight = 0;
    }
    
    if(_hasSearchBar){
        _searchBarBackgroundView.hidden = NO;
    }else{
        _searchBarBackgroundView.hidden = YES;
    }
    
    if(_hasToolBar){
        _tagListView.hidden = NO;
        _tagListView.frame = CGRectMake(0, 44 + searchBarHeight, self.frame.size.width, _tagListView.frameHeight);
        _tagListView.backgroundColor = VZ_RGBA(0xffffff, 0.8);
        [self addSubview:_tagListView];
        
        _toolBarLineView.hidden = NO;
        _toolBarLineView.frame = CGRectMake(0, CGRectGetMaxY(_tagListView.frame) , _toolBarLineView.frame.size.width, 1);
        _toolBarLineView.layer.zPosition = 1000;
        
        toolBarHeight = _tagListView.frameHeight;
    }else{
        _tagListView.hidden = YES;
        _toolBarLineView.hidden = YES;
        toolBarHeight = 0;
    }
    
    self.tableView.frame = CGRectMake(0, 44 + toolBarHeight + searchBarHeight, _contentFrame.size.width, _contentFrame.size.height - toolBarHeight - searchBarHeight -44);
}

- (void)setToolBarHidden:(BOOL)hidden{
    _tagListView.hidden = hidden;
    _toolBarLineView.hidden = hidden;
}


- (void)setTagViewTapListener:(VZInspectorTagViewTap)tagViewTapListener{
    if(_tagListView){
        _tagListView.tagViewTap = tagViewTapListener;
    }
}

- (void)setTitle:(NSString *)title{
    if(_dragView){
        _dragView.text = title ?:@"";
        _title = title;
    }
}

- (void)setLeftButtonTitle:(NSString *)leftButtonTitle{
    if(_backButton && leftButtonTitle != nil){
        [_backButton setTitle:leftButtonTitle forState:UIControlStateNormal];
        _leftButtonTitle = leftButtonTitle;
    }
}

- (void)setRightButtonTitle:(NSString *)rightButtonTitle{
    if(_clearButton && rightButtonTitle != nil){
        [_clearButton setTitle:rightButtonTitle forState:UIControlStateNormal];
        _rightButtonTitle = rightButtonTitle;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //subclass todo
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self itemForCellAtIndexPath:indexPath].itemHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //拿到当前的item
    VZInspectorBizLogItem *item = [self itemForCellAtIndexPath:indexPath];
    //拿到当前cell的类型
    Class cellClass = item.cellClass;
    //拿到name
    NSString* identifier = NSStringFromClass(cellClass);
    //创建cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if ([cell isKindOfClass:[VZInspectorBizLogCell class]])
    {
        VZInspectorBizLogCell* customCell = (VZInspectorBizLogCell*)cell;
        customCell.indexPath = indexPath;
        
        if (item)
        {
            //为cell,item绑定index
            item.indexPath = indexPath;
            [customCell setItem:item];
        }
        else
        {
            VZInspectorBizLogItem* item = [VZInspectorBizLogItem new];
            item.itemHeight = 44;
            item.indexPath = indexPath;
            [(VZInspectorBizLogCell *)cell setItem:item];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   //subclass todo
}

- (VZInspectorBizLogItem *)itemForCellAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    if(row < self.items.count){
        return self.items[row];
    }else{
        return  [VZInspectorBizLogItem new];
    }
}

- (NSMutableArray *)items{
    if(!_items){
        _items = [[NSMutableArray alloc]init];
    }
    return _items;
}

- (void)reloadDatas{
    // subclass todo
}

- (void)addDragTagGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer{
    [self.dragView addGestureRecognizer:gestureRecognizer];
}

- (void)onCancle{
    
    [self leftButtonClick];
    if(self.delegate && [self.delegate respondsToSelector:@selector(onClickCancleButton)]){
        [self.delegate onClickCancleButton];
    }
}

- (void)onClear{
    [self rightButtonClick];
    if(self.delegate && [self.delegate respondsToSelector:@selector(onClickClearButton)]){
        [self.delegate onClickClearButton];
    }
}

- (void)leftButtonClick{
    
}

- (void)rightButtonClick{
    
}


-(void)textFieldTextDidChange:(UITextField *)textField{
    
}



@end
