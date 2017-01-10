//
//  VZToolboxView.m
//  VZInspector
//
//  Created by lingwan on 15/4/16.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import <objc/runtime.h>

#import "VZInspectorToolboxView.h"
#import "VZInspectorResource.h"
#import "VZDefine.h"

#define kVZInspectorToolItemCellReuseId @"kVZInspectorToolItemCellReuseId"


@interface VZInspectorToolItemCell : UICollectionViewCell

@property (nonatomic, strong) VZInspectorToolItem *item;

@end

@implementation VZInspectorToolItemCell
{
    UIImageView *_iconView;
    UILabel *_nameLabel;
    UILabel *_statusLabel;
    UIView *_statusView;
}

- (void)setItem:(VZInspectorToolItem *)item {
    _item = item;
    _iconView.image = item.icon;
    _nameLabel.text = item.name;
    _statusView.hidden = !item.status;
    _statusLabel.text = item.status;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.clipsToBounds = YES;
        self.layer.borderWidth = kOnePix;
        self.layer.borderColor = VZ_INSPECTOR_MAIN_COLOR.CGColor;
        
        const CGFloat textHeight = 15;
        const CGFloat imageSize = 32;
        const CGFloat spacing = 3;
        const CGFloat totalHeight = textHeight + spacing + imageSize;
        
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - imageSize) / 2, (frame.size.height - totalHeight) / 2, imageSize, imageSize)];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_iconView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _iconView.frame.origin.y + imageSize + spacing, frame.size.width, textHeight)];
        _nameLabel.font = [UIFont systemFontOfSize:12.0];
        _nameLabel.textColor = VZ_INSPECTOR_MAIN_COLOR;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        
        CGFloat w = frame.size.width;
        _statusView = [[UIView alloc] init];
        _statusView.layer.anchorPoint = CGPointMake(1, 1);
        _statusView.frame = CGRectMake(w - w * M_SQRT2 / 2, w / 2 - w * M_SQRT2 / 8, w * M_SQRT2 / 2, w * M_SQRT2 / 8);
        _statusView.transform = CGAffineTransformMakeRotation(M_PI_4);
        _statusView.backgroundColor = VZ_INSPECTOR_MAIN_COLOR;
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(w * M_SQRT2 / 8, 0, w * M_SQRT2 / 4, w * M_SQRT2 / 8)];
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.font = [UIFont systemFontOfSize:10];
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.minimumScaleFactor = 0.7;
        [_statusView addSubview:_statusLabel];
        [self.contentView addSubview:_statusView];
    }
    return self;
}

@end


@interface VZInspectorToolboxView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *tools;

@end


@implementation VZInspectorToolboxView
{
    UICollectionView *_collectionView;
    UIImageView *_logoView;
    UIView *_emptyView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.itemSize = CGSizeMake(frame.size.width / 5, frame.size.width / 5);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 120, frame.size.width, frame.size.height - 120) collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.bounces = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[VZInspectorToolItemCell class] forCellWithReuseIdentifier:kVZInspectorToolItemCellReuseId];
        [self addSubview:_collectionView];
        
        _logoView = [[UIImageView alloc]initWithFrame:CGRectMake((frame.size.width - 60)/2, 30, 60, 60)];
        _logoView.image = [VZInspectorResource logo];
        _logoView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_logoView];
        
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, _collectionView.frame.origin.y, frame.size.width, 1)];
        line.backgroundColor = VZ_INSPECTOR_MAIN_COLOR;
        [self addSubview:line];
        
        UILabel *label = [[UILabel alloc] initWithFrame:_collectionView.frame];
        label.text = @"No Plugins";
        label.textColor = VZ_INSPECTOR_MAIN_COLOR;
        label.font = [UIFont systemFontOfSize:24];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _emptyView = label;
    }
    
    return self;
}

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (void)setIcon:(UIImage *)icon {
    _logoView.image = icon;
}

- (NSMutableArray *)tools {
    if (!_tools) {
        _tools = [NSMutableArray array];
    }
    return _tools;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tools.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VZInspectorToolItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVZInspectorToolItemCellReuseId forIndexPath:indexPath];
    cell.item = self.tools[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    VZInspectorToolItem *item = self.tools[indexPath.item];
    [item performAction];
    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [VZ_INSPECTOR_MAIN_COLOR colorWithAlphaComponent:0.3];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
}

- (void)addToolItem:(VZInspectorToolItem *)toolItem {
    [self.tools addObject:toolItem];
    _emptyView.hidden = YES;
}

- (void)updateCollectionView{
    if(_collectionView){
        [_collectionView reloadData];
    }
}

@end
