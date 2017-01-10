//
//  VZInspectorMermoryView.m
//  APInspector
//
//  Created by 净枫 on 2016/12/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorMermoryView.h"
#import "VZInspectorMermoryDataHelper.h"
#import "VZInspectorMermoryItem.h"
#import "VZInspectorMermoryUtil.h"
#import "VZInspectorMermoryRetainCycleResultItem.h"
#import "VZInspectorMaskView.h"
#import "VZInspectorMermoryRetainCycleMaskView.h"
#import "VZInspectorTagView.h"
#import "VZDefine.h"
#import "VZInspectorUtility.h"

typedef NS_ENUM(NSUInteger , VZInspectorMermoryViewState){
    VZInspectorMermoryViewStateClassName = 0,
    VZInspectorMermoryViewStateInstance
};

typedef NS_ENUM(NSUInteger , VZInspectorMermoryViewToolBar){
    VZInspectorMermoryViewToolBarCheck = 0,
    VZInspectorMermoryViewToolBarRetainCycleResult,
    VZInspectorMermoryViewToolBarOpenCheck
};

@interface VZInspectorMermoryView()<UIAlertViewDelegate>

@property (nonatomic, strong) VZInspectorMaskView *maskView;

@property (nonatomic, assign) VZInspectorMermoryViewState state;

@property (nonatomic, assign) CGRect mermoryTableViewFrame;

@property (nonatomic, assign) CGRect meomoryInstanceTableViewFrame;

@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, assign) BOOL isMainView;

@property (nonatomic, assign) BOOL isChecking;

@property (nonatomic, assign) BOOL isCheckStoping;

@property (nonatomic, weak) VZInspectorTagView *switchTagView;

@end

@implementation VZInspectorMermoryView{
    NSTimer *_timer;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        _meomoryInstanceTableViewFrame = CGRectMake(0,44 , frame.size.width, frame.size.height - 44);
        
        self.title = @"内存对象";
        self.rightButtonTitle = @"";
        self.hasSearchBar = YES;
        _isMainView = YES;
        _isChecking = NO;
        _isCheckStoping = NO;
        _state = VZInspectorMermoryViewStateClassName;
        [self addToolBarViews];
        _mermoryTableViewFrame = self.tableView.frame;

        
        _timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                  target:self
                                                selector:@selector(_loadDataFromTimer:)
                                                userInfo:nil
                                                 repeats:YES];
        [_timer fire];

    }
    return self;
}

- (void)addToolBarViews{
    NSMutableArray *toolBarItems = [[NSMutableArray alloc]init];

    [toolBarItems addObject:[VZInspectorBizLogToolBarItem normalToolBarItemWithNormalTitle:@"循环依赖"  selectedTitle:@"" type:VZInspectorMermoryViewToolBarRetainCycleResult  isSelected:NO groupId:0]];
    
    [toolBarItems addObject:[VZInspectorBizLogToolBarItem normalToolBarItemWithNormalTitle:@"  检查所有循环依赖  " selectedTitle:@"" type:VZInspectorMermoryViewToolBarCheck onlyClick:YES]];
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    BOOL checkSwitch;
    if(defaults){
        checkSwitch = [[defaults objectForKey:KVZInspectorMermoryCheckSwitch] boolValue];
    }
    [toolBarItems addObject:[VZInspectorBizLogToolBarItem normalToolBarItemWithNormalTitle:@"开启检查" selectedTitle:@"关闭检查" type:VZInspectorMermoryViewToolBarOpenCheck isSelected:checkSwitch]];
    
    self.toolBarItems = toolBarItems;

    __weak typeof(self) weakSelf = self;
    self.tagViewTapListener = ^(NSArray *tagItems){
        if(tagItems.count > 0){
            [tagItems enumerateObjectsUsingBlock:^(VZInspectorTagView *tagView, NSUInteger idx, BOOL * _Nonnull stop) {
                if(tagView.item.type == VZInspectorMermoryViewToolBarRetainCycleResult){
                    [weakSelf retainCycleButtonClick:tagView.item.isSelected];
                }else if(tagView.item.type == VZInspectorMermoryViewToolBarCheck){
                    [weakSelf checkAllRetainCycles:tagView];
                }else if(tagView.item.type == VZInspectorMermoryViewToolBarOpenCheck){
                   
                    weakSelf.switchTagView = tagView;
                    if(tagView.item.isSelected){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否开启检查" message:@"⚠️开启检查会关闭应用，请重启开始检查" delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"确定" , nil];
                        [alert show];
                    }else{
                        NSUserDefaults *mermoryDefaults =[NSUserDefaults standardUserDefaults];
                        [mermoryDefaults setObject:@(NO) forKey:KVZInspectorMermoryCheckSwitch];
                        [mermoryDefaults synchronize];
                        [[VZInspectorMermoryDataHelper sharedInstance] updateMermoryTrackState:NO];
                        [[VZInspectorMermoryDataHelper sharedInstance] endTrackingIfNeed];
                        [[NSNotificationCenter defaultCenter] postNotificationName:KVZInspectorMermoryCheckStatusChange object:nil];
                    }
                }

            }];
        }
        
    };

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        NSUserDefaults *mermoryDefaults =[NSUserDefaults standardUserDefaults];
        [mermoryDefaults setObject:@(YES) forKey:KVZInspectorMermoryCheckSwitch];
        [mermoryDefaults synchronize];
        [[VZInspectorMermoryDataHelper sharedInstance] updateMermoryTrackState:YES];
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        exit(0);
    }else if(buttonIndex == 0){
        if(self.switchTagView){
            [self.tagListView setSelectedTagView:self.switchTagView];
        }

    }
}

//- (void)alertViewCancel:(UIAlertView *)alertView{
//    if(self.switchTagView){
//        [self.tagListView setSelectedTagView:self.switchTagView];
//    }
//}

- (void)retainCycleButtonClick:(BOOL)retainCycle{
    if(_state == VZInspectorMermoryViewStateClassName){
        self.items = [[[VZInspectorMermoryDataHelper sharedInstance] mermoryDatasForRetainCycle:retainCycle] mutableCopy];
        [self.tableView reloadData];
    }
}

- (void)checkAllRetainCycles:(VZInspectorTagView *)tagView{
    if(!_isChecking){
        _isChecking = YES;
        UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGSize tagViewSize = tagView.frame.size;
        [loadingIndicator setFrame:CGRectMake( (tagViewSize.width - 20)/2 , (tagViewSize.height -20)/2,20,20)];
        loadingIndicator.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
        loadingIndicator.tag = 19999;
        loadingIndicator.color = VZ_INSPECTOR_MAIN_COLOR;
        loadingIndicator.userInteractionEnabled = NO;
        [loadingIndicator startAnimating];
        [tagView addSubview:loadingIndicator];
        
        CGSize stopLabelSize = VZ_TextSizeFrame(@"STOP (", 13);
        UILabel *stopLabel = [VZInspectorUtility simpleLabel:CGRectMake(0, 0, stopLabelSize.width, 20) f:13 tc:VZ_RGB(0x888888) t:@"STOP ("];
        stopLabel.tag = 39999;
        stopLabel.textAlignment = NSTextAlignmentCenter;
        [tagView addSubview:stopLabel];
        
        NSUInteger maxCount = self.items.count;
        
        UILabel *progressLabel = nil;
        if(maxCount > 0){
            NSString *maxTitle = [NSString stringWithFormat:@"%d/%d )" , maxCount ,maxCount];
            CGSize progressMaxSize = VZ_TextSizeFrame(maxTitle, 13);
            CGFloat stopLabelX = (tagViewSize.width - stopLabelSize.width - 20 - progressMaxSize.width - 5)/2;
            CGFloat loadingIndicatorX = stopLabelX + stopLabelSize.width;
            CGFloat progressX = loadingIndicatorX + 22;
            progressLabel = [VZInspectorUtility simpleLabel:CGRectMake(progressX, (tagView.frame.size.height -20)/2, progressMaxSize.width + 3, 20) f:13 tc:VZ_RGB(0x888888) t:@""];
            progressLabel.textAlignment = NSTextAlignmentCenter;
            progressLabel.tag = 29999;
            progressLabel.text = [NSString stringWithFormat:@"1/%d )" , maxCount];
            [tagView addSubview:progressLabel];
            stopLabel.frame = CGRectMake(stopLabelX, (tagViewSize.height -20)/2, stopLabelSize.width, 20);
            loadingIndicator.frame = CGRectMake(loadingIndicatorX, (tagViewSize.height -20)/2, 20, 20);
        }else{
            CGFloat stopLabelX = (tagViewSize.width - stopLabelSize.width - 20 - 2 - 10)/2;
            CGFloat loadingIndicatorX = stopLabelX + stopLabelSize.width;
            CGFloat progressX = loadingIndicatorX + 30;
            stopLabel.frame = CGRectMake(stopLabelX, (tagViewSize.height -20)/2, stopLabelSize.width, 20);
            loadingIndicator.frame = CGRectMake(loadingIndicatorX, (tagViewSize.height -20)/2, 20, 20);

        }

        [tagView setTitle:@"" forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        __weak UILabel *weakProgressLabel = progressLabel;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            NSArray *checkItems ;
            @synchronized (weakSelf) {
                checkItems = [weakSelf.items copy];
            }
            NSUInteger checkItemsCount = checkItems.count;
            for (NSUInteger i = 0; i < checkItemsCount; i++) {
                
                if(weakSelf.isCheckStoping){
                
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf stopCheckRetainCycleForTagView:tagView];
                        weakSelf.isChecking = NO;
                        weakSelf.isCheckStoping = NO;
                    });
                    break;
                }
                id object = checkItems[i];
                if([object isKindOfClass:[VZInspectorMermoryItem class]]){
                    VZInspectorMermoryItem *item = (VZInspectorMermoryItem *)object;
                    NSArray *retainCycles = [[VZInspectorMermoryDataHelper sharedInstance] findRetainCyclesForInstances:item.className];
                    
                    if(i < checkItemsCount -1){
                        VZInspectorMermoryItem *nextItem = (VZInspectorMermoryItem *)checkItems[i+1];
                        [[VZInspectorMermoryDataHelper sharedInstance] setClassLoadingStatus:YES className:nextItem.className];
                    }
                    [[VZInspectorMermoryDataHelper sharedInstance] setClassLoadingStatus:NO className:item.className];
                    weakSelf.items = [[[VZInspectorMermoryDataHelper sharedInstance]mermoryDatas] mutableCopy];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                        if(weakProgressLabel && (i < checkItemsCount -1)){
                            weakProgressLabel.text = [NSString stringWithFormat:@"%d/%d )" , (i+2) , checkItemsCount];
                        }
                    });
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf stopCheckRetainCycleForTagView:tagView];
                weakSelf.isChecking = NO;
                weakSelf.isCheckStoping = NO;
            });
        });
    }else if(!_isCheckStoping){
        _isCheckStoping = YES;
        UIView *indicatorView = [tagView viewWithTag:19999];
        UIView *progressView = [tagView viewWithTag:29999];
        UIView *stopLabel = [tagView viewWithTag:39999];
        
        if(stopLabel == nil){
            return;
        }
        CGSize stopLabelSize = VZ_TextSizeFrame(@"STOPING (", 13);
        CGSize indicatorSize = indicatorView.frame.size;
        CGSize tagViewSize = tagView.frame.size;

        ((UILabel *)stopLabel).text = @"STOPING (";
        
        if(progressView){
            CGSize progressSize = progressView.frame.size;
            CGFloat stopLabelX = (tagViewSize.width - stopLabelSize.width - 20 - progressSize.width )/2;
            CGFloat loadingIndicatorX = stopLabelX + stopLabelSize.width;
            CGFloat progressX = loadingIndicatorX + 22;
            stopLabel.frame = CGRectMake(stopLabelX, (tagViewSize.height -20)/2, stopLabelSize.width, 20);
            indicatorView.frame = CGRectMake(loadingIndicatorX, (tagViewSize.height -20)/2, 20, 20);
            progressView.frame = CGRectMake(progressX, (tagViewSize.height -20)/2, progressSize.width , 20);
        }else{
            CGFloat stopLabelX = (tagViewSize.width - stopLabelSize.width - 20 - 2 - 10)/2;
            CGFloat loadingIndicatorX = stopLabelX + stopLabelSize.width;
            CGFloat progressX = loadingIndicatorX + 30;
            stopLabel.frame = CGRectMake(stopLabelX, (tagViewSize.height -20)/2, stopLabelSize.width, 20);
            indicatorView.frame = CGRectMake(loadingIndicatorX, (tagViewSize.height -20)/2, 20, 20);
        }
        
        
        
    }
}

- (void)stopCheckRetainCycleForTagView:(VZInspectorTagView *)tagView{
    UIView *view = [tagView viewWithTag:19999];
    UIView *progressView = [tagView viewWithTag:29999];
    UIView *stopLabel = [tagView viewWithTag:39999];
    if([view isKindOfClass:[UIActivityIndicatorView class]]){
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)view;
        [indicator stopAnimating];
        
        [indicator removeFromSuperview];
        indicator = nil;
        
    }
    if(progressView){
        [progressView removeFromSuperview];
        progressView =nil;
    }
    
    if(stopLabel){
        [stopLabel removeFromSuperview];
        stopLabel = nil;
    }
    [tagView setTitle:tagView.item.normalTitle forState:UIControlStateNormal];
    
}

- (void)_loadDataFromTimer:(NSTimer *)timer{
    
    if(![[VZInspectorMermoryDataHelper sharedInstance] canMermoryTrack]){
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _loadData];
    });
}

- (void)_loadData
{
    if(_isMainView){
        if(_state == VZInspectorMermoryViewStateClassName){
            self.items = [[[VZInspectorMermoryDataHelper sharedInstance] mermoryDatas] mutableCopy];
        }
        [self.tableView reloadData];

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    VZInspectorBizLogItem *item = [self itemForCellAtIndexPath:indexPath];
    if(item && [item isKindOfClass:[VZInspectorMermoryItem class]]){
        if(_isChecking){
            return;
        }
        VZInspectorMermoryItem *mermoryItem = (VZInspectorMermoryItem *)item;
        if(!mermoryItem.isLoading){
            mermoryItem.isLoading = YES;
            [[VZInspectorMermoryDataHelper sharedInstance] setClassLoadingStatus:YES className:mermoryItem.className];
            [self.tableView reloadData];
            [self findRetainCyclesForClassName:mermoryItem.className];
        }
        
    }else if(item && [item isKindOfClass:[VZInspectorMermoryRetainCycleResultItem class]]){
        UIView *rootView = [[UIApplication sharedApplication] keyWindow];
        _maskView = [[VZInspectorMermoryRetainCycleMaskView alloc]initWithFrame:CGRectZero rootView:rootView data:item];
        _maskView.delegate = self;
        _maskView.canceledOnTouchOutside = YES;
        [_maskView showMaskView];
    }
}

- (void)cancleMaskView{
    if(_maskView){
        [_maskView hideMaskView];
        _maskView = nil;
    }
}


- (void)findRetainCyclesForClassName:(NSString *)className{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *retainCycles = [[VZInspectorMermoryDataHelper sharedInstance] findRetainCyclesForInstances:className];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[VZInspectorMermoryDataHelper sharedInstance] setClassLoadingStatus:NO className:className];
            if(retainCycles.count == 1){
                UIView *rootView = [[UIApplication sharedApplication] keyWindow];
                _maskView = [[VZInspectorMermoryRetainCycleMaskView alloc]initWithFrame:CGRectZero rootView:rootView data:retainCycles[0]];
                _maskView.delegate = self;
                _maskView.canceledOnTouchOutside = YES;
                [_maskView showMaskView];
            }else if(retainCycles.count > 1){
                self.items = retainCycles;
                self.state = VZInspectorMermoryViewStateInstance;
            }else{
                self.items = [[[VZInspectorMermoryDataHelper sharedInstance]mermoryDatas] mutableCopy];
                self.state = VZInspectorMermoryViewStateClassName;
            }
            [self.tableView reloadData];
        });
    });
}

- (void)setState:(VZInspectorMermoryViewState)state{
    if(state == _state){
        return;
    }
    _state = state;
    if(state == VZInspectorMermoryViewStateClassName){
        self.title = @"内存对象";
        self.rightButtonTitle = @"";
        self.searchBarBackgroundView.hidden = NO;
        [self setToolBarHidden:NO];
        self.tableView.frame = _mermoryTableViewFrame;
        self.tableView.contentOffset = _contentOffset;
        _isMainView = YES;
    }else if(state == VZInspectorMermoryViewStateInstance){
        self.title = @"循环依赖";
        self.rightButtonTitle = @"Back";
        self.searchBarBackgroundView.hidden = YES;
        [self setToolBarHidden:YES];
        _contentOffset = self.tableView.contentOffset;
        self.tableView.frame = _meomoryInstanceTableViewFrame;
        self.tableView.contentOffset = CGPointMake(0, 0);
        _isMainView = NO;
    }
}

- (void)rightButtonClick{
    if(_state == VZInspectorMermoryViewStateInstance){
        self.state = VZInspectorMermoryViewStateClassName;
        self.items = [[[VZInspectorMermoryDataHelper sharedInstance] mermoryDatas] mutableCopy];
        [self.tableView reloadData];
    }
}

- (void)textFieldTextDidChange:(UITextField *)textField{
    
    if(textField){
        NSString *searchText = textField.text;
        self.items = [[[VZInspectorMermoryDataHelper sharedInstance] filterMermoryDatas:searchText] mutableCopy];
        [self.tableView reloadData];
    }
}



@end
