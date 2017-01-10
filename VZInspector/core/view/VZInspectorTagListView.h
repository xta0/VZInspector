//
//  TagListView.h
//  TagObjc
//
//  Created by Javi Pulido on 16/7/15.
//  Copyright (c) 2015 Javi Pulido. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZInspectorBizLogToolBarItem.h"

@class VZInspectorTagView;

typedef void (^VZInspectorTagViewTap)(NSArray *);


@interface VZInspectorTagListView : UIView

@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *tagBackgroundColor;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) CGFloat paddingY;
@property (nonatomic) CGFloat paddingX;
@property (nonatomic) CGFloat marginY;
@property (nonatomic) CGFloat marginX;
@property (nonatomic) UIFont *textFont;


@property (nonatomic) CGFloat tagViewHeight;
@property (nonatomic ,assign)CGFloat frameHeight;
@property (nonatomic) NSMutableArray *tagViews;
@property (nonatomic) int rows;

@property (nonatomic ,strong)VZInspectorTagViewTap tagViewTap;

- (void)addTagItems:(NSArray<VZInspectorBizLogToolBarItem *> *)tagItems;
- (VZInspectorTagView *)addTag:(NSString *)title;
- (void)removeTag:(NSString *)title;
- (void)removeAllTags;

- (void)setSelectedTagView:(VZInspectorTagView *)tagView;

@end
