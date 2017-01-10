//
//  TagListView.m
//  TagObjc
//
//  Created by Javi Pulido on 16/7/15.
//  Copyright (c) 2015 Javi Pulido. All rights reserved.
//

#import "VZInspectorTagListView.h"
#import "VZInspectorTagView.h"
#import "VZDefine.h"

@interface VZInspectorTagListView ()

@property(nonatomic , weak) VZInspectorTagView* currentTagView;

@property(nonatomic , strong) NSMutableDictionary *selectedTagViews;

@end

@implementation VZInspectorTagListView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        _textFont = [UIFont systemFontOfSize:14];
        _tagBackgroundColor = [UIColor whiteColor];
        _cornerRadius = 5;
        _borderWidth = 1;
        _borderColor = VZ_RGB(0xbdc8d0);
        _paddingY = 6;
        _paddingX = 10;
        _textColor = VZ_RGB(0x000000);
        _marginX = 5;
        _marginY = 5;
    }
    return self;
}

- (NSMutableDictionary *)selectedTagViews{
    if(!_selectedTagViews){
        _selectedTagViews = [[NSMutableDictionary alloc] init];
    }
    return _selectedTagViews;
}

- (void)setSelectedTagView:(VZInspectorTagView *)tagView{
    if(!(tagView && tagView.item)){
        return;
    }
    NSMutableArray *tagViewsForGroupid = [self.selectedTagViews objectForKey:@(tagView.item.groupId)];
    if(!vz_IsArrayValid(tagViewsForGroupid)){
        tagViewsForGroupid = [[NSMutableArray alloc]init];
        [self.selectedTagViews setObject:tagViewsForGroupid forKey:@(tagView.item.groupId)];
    }
    if(tagView.item.groupId == 0){
        if([tagViewsForGroupid containsObject:tagView]){
            if(tagView.item.isSelected){
                tagView.item.isSelected = NO;
                [self setSelectedTagView:tagView selected:NO];
                [tagViewsForGroupid removeObject:tagView];
            }
        }else{
            tagView.item.isSelected = YES;
            [self setSelectedTagView:tagView selected:YES];
            [tagViewsForGroupid addObject:tagView];
        }
    }else{
        
        //分组的tagView管理
        if(![tagViewsForGroupid containsObject:tagView]){
            __weak typeof(self) weakSelf = self;
            [tagViewsForGroupid enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if([obj isKindOfClass:[VZInspectorTagView class]]){
                    VZInspectorTagView *tagView = (VZInspectorTagView *)obj;
                    tagView.item.isSelected = NO;
                    [weakSelf setSelectedTagView:tagView selected:NO];
                }
            }];
            tagView.item.isSelected = YES;
            [self setSelectedTagView:tagView selected:YES];
            [tagViewsForGroupid removeAllObjects];
            [tagViewsForGroupid addObject:tagView];
        }
        
    }
}

- (NSMutableArray *)tagViews {
    if(!_tagViews) {
        [self setTagViews:[[NSMutableArray alloc] init]];
    }
    return _tagViews;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    for(VZInspectorTagView *tagView in [self tagViews]) {
        [tagView setTextColor:textColor];
    }
}

- (void)setTagBackgroundColor:(UIColor *)tagBackgroundColor {
    _tagBackgroundColor = tagBackgroundColor;
    for(VZInspectorTagView *tagView in [self tagViews]) {
        [tagView setBackgroundColor:tagBackgroundColor];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    for(VZInspectorTagView *tagView in [self tagViews]) {
        [tagView setCornerRadius:cornerRadius];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    for(VZInspectorTagView *tagView in [self tagViews]) {
        [tagView setBorderWidth:borderWidth];
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    for(VZInspectorTagView *tagView in [self tagViews]) {
        [tagView setBorderColor:borderColor];
    }
}

- (void)setPaddingY:(CGFloat)paddingY {
    _paddingY = paddingY;
    for(VZInspectorTagView *tagView in [self tagViews]) {
        [tagView setPaddingY:paddingY];
    }
}

- (void)setPaddingX:(CGFloat)paddingX {
    _paddingX = paddingX;
    for(VZInspectorTagView *tagView in [self tagViews]) {
        [tagView setPaddingX:paddingX];
    }
}

- (void)setMarginY:(CGFloat)marginY {
    _marginY = marginY;
    [self rearrangeViews];
}

- (void)setMarginX:(CGFloat)marginX {
    _marginX = marginX;
    [self rearrangeViews];
}

- (void)setRows:(int)rows {
    _rows = rows;
    [self invalidateIntrinsicContentSize];
}

# pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self rearrangeViews];
}

- (void)rearrangeViews {
    for(VZInspectorTagView *tagView in [self tagViews]) {
        [tagView removeFromSuperview];
    }
    
    int currentRow = 0;
    int currentRowTagCount = 0;
    CGFloat currentRowWidth = 0;
    CGFloat viewHeight = 0;
    for(VZInspectorTagView *tagView in [self tagViews]) {
        CGRect tagViewFrame = tagView.frame;
        tagViewFrame.size = [tagView intrinsicContentSize];
        self.tagViewHeight = tagViewFrame.size.height;
        
        if (currentRowTagCount == 0 || (currentRowWidth + tagView.frame.size.width + [self marginX]) > self.frame.size.width) {
            currentRow += 1;
            CGRect tempFrame = CGRectZero;
            tempFrame.origin.x = [self marginX];
            tempFrame.origin.y = (currentRow - 1) * (self.tagViewHeight + self.marginY) + self.marginY;
            tempFrame.size = tagViewFrame.size;
            [tagView setFrame:tempFrame];
            
            currentRowTagCount = 1;
            currentRowWidth =self.marginX +  tagView.frame.size.width + self.marginX;
            
            viewHeight += self.marginY + self.tagViewHeight;
        } else {
            CGRect tempFrame = CGRectZero;
            tempFrame.origin.x = currentRowWidth;
            tempFrame.origin.y = (currentRow - 1) *(self.tagViewHeight + self.marginY) + self.marginY;
            tempFrame.size = tagViewFrame.size;
            [tagView setFrame:tempFrame];
            
            currentRowTagCount += 1;
            currentRowWidth += tagView.frame.size.width + self.marginX;
        }
        
        [self addSubview:tagView];
    }
    
    viewHeight += self.marginY;
    self.frameHeight = viewHeight;
    self.rows = currentRow;
}

//- (CGFloat)frameHeight{
//    int currentRow = 0;
//    int currentRowTagCount = 0;
//    CGFloat currentRowWidth = 0;
//    CGFloat viewHeight = 0;
//    for(VZInspectorTagView *tagView in self.tagViews){
//        CGSize size = [tagView intrinsicContentSize];
//        if (currentRowTagCount == 0 || (currentRowWidth + tagView.frame.size.width + [self marginX]) > self.frame.size.width) {
//            currentRow += 1;
//            currentRowTagCount = 1;
//            currentRowWidth =self.marginX +  tagView.frame.size.width + self.marginX;
//            
//            viewHeight += self.marginY + self.tagViewHeight;
//
//        }else{
//            currentRowTagCount += 1;
//            currentRowWidth += tagView.frame.size.width + self.marginX;
//        }
//    }
//    
//    viewHeight +=self.marginY;
//
//    return viewHeight;
//}



# pragma mark - Manage tags

- (CGSize) intrinsicContentSize {
    CGFloat height = [self rows] * ([self tagViewHeight] + [self marginY]);
    if([self rows] > 0) {
        height -= [self marginY];
    }
    return CGSizeMake(self.frame.size.width, height);
}

- (VZInspectorTagView *)generationTagView:(VZInspectorBizLogToolBarItem *)tagItem {
    VZInspectorTagView *tagView = [[VZInspectorTagView alloc] initWithTitle:tagItem.normalTitle];
    
    if(tagItem.normalTitleColor){
        [tagView setTextColor:tagItem.normalTitleColor];
    }else{
        [tagView setTextColor: _textColor];
    }
    
    if(tagItem.normalBackgroundColor){
        [tagView setBackgroundColor: tagItem.normalBackgroundColor];
    }else{
        [tagView setBackgroundColor: _tagBackgroundColor];
    }
    
    if(tagItem.normalBorderColor){
        [tagView setBorderColor: tagItem.normalBorderColor];
    }else{
        [tagView setBorderColor: _borderColor];
    }
    
    if(tagItem.isSelected){
        if(tagItem.selectedBorderColor){
            [tagView setBorderColor:tagItem.selectedBorderColor];
        }
    }
    
    [tagView setCornerRadius: _cornerRadius];
    [tagView setBorderWidth: _borderWidth];
    [tagView setPaddingY: _paddingY];
    [tagView setPaddingX: _paddingX];
    [tagView setTextFont: _textFont];
    
    tagView.item = tagItem;
    
    [tagView addTarget:self action:@selector(tagPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return tagView;
}

- (void)addTagItem:(VZInspectorBizLogToolBarItem *)item{
    VZInspectorTagView *tagView = [self generationTagView:item];
    if(tagView){
        [self.tagViews addObject:tagView];
    }
    [self rearrangeViews];
}

- (void)addTagItems:(NSArray<VZInspectorBizLogToolBarItem *> *)tagItems{
    
    if(tagItems && [tagItems isKindOfClass:[NSArray class]] && tagItems.count > 0){
        for(VZInspectorBizLogToolBarItem *tagItem in tagItems){
            VZInspectorTagView *tagView = [self generationTagView:tagItem];
            if(tagView){
                [self.tagViews addObject:tagView];
                if(tagView.item.isSelected){
                    [self setSelectedTagView:tagView];
                }
            }
        }
        
        [self rearrangeViews];
    }
    
}

- (void)removeTag:(VZInspectorBizLogToolBarItem *)item {
    for(int index = (int)[[self tagViews] count] - 1 ; index <= 0; index--) {
        VZInspectorTagView *tagView = [[self tagViews] objectAtIndex:index];
        if(tagView.item == item ) {
            [tagView removeFromSuperview];
            [[self tagViews] removeObjectAtIndex:index];
            break;
        }
    }
}

- (void)removeAllTags {
    for(VZInspectorTagView *tagView in [self tagViews]) {
        [tagView removeFromSuperview];
    }
    [self setTagViews:[[NSMutableArray alloc] init]];
    [self rearrangeViews];
}

- (void)tagPressed:(VZInspectorTagView *)tagView {
    if ([tagView isKindOfClass:[VZInspectorTagView class]]) {
        
        if(tagView.item.onlyClick){
            
            if(self.tagViewTap){
                NSArray *items = @[tagView];
                self.tagViewTap(items);
            }
            
        }else if(tagView.item.groupId == 0){
            //如果是groupId == 0， 则每次点击都返回事件
            if([self isValidClick:tagView]){
                [self setSelectedTagView:tagView];
                NSMutableArray *allSelectedViews = [[NSMutableArray alloc]init];
                if(![allSelectedViews containsObject:tagView]){
                    [allSelectedViews addObject:tagView];
                }
                
                if(self.tagViewTap){
                    self.tagViewTap(allSelectedViews);
                }
            }
        }else{
            if([self isValidClick:tagView]){
                
                [self setSelectedTagView:tagView];
                
                // 得到所有当前选中的tagView的item返回
                NSArray *allSelectedViews = [self allSelectedTagViews];
                
                if(self.tagViewTap){
                    self.tagViewTap(allSelectedViews);
                }
            }
        }
        
    }
}

- (NSArray *)allSelectedTagViews{
    __block NSMutableArray *selectedViews = [[NSMutableArray alloc]init];
    [self.selectedTagViews enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if(vz_IsArrayValid(obj)){
            NSArray *tagViews = (NSArray *)obj;
            [tagViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if([obj isKindOfClass:[VZInspectorTagView class]]){
                    VZInspectorTagView *tagView = (VZInspectorTagView *)obj;
                    [selectedViews addObject:tagView];
                }
            }];
        }
    }];
    return [selectedViews copy];
}

- (BOOL)isValidClick:(VZInspectorTagView *)tagView{
    
    if(tagView && tagView.item){
        NSArray *tagViewsForGroupId = [self.selectedTagViews objectForKey:@(tagView.item.groupId)];
        if([tagViewsForGroupId containsObject:tagView] && tagView.item.groupId != 0){
            return NO;
        }else{
            return YES;
        }
    }
    
    return NO;
}

- (void)setSelectedTagView:(VZInspectorTagView *)tagView selected:(BOOL)selected{
   
    if([tagView isKindOfClass:[VZInspectorTagView class]]){
        if(selected){
            VZInspectorBizLogToolBarItem *tagItem = tagView.item;
            if(tagItem.selectedTitleColor){
                [tagView setTextColor:tagItem.selectedTitleColor];
            }
            
            if(tagItem.selectedbackgroundColor){
                [tagView setBackgroundColor: tagItem.selectedbackgroundColor];
            }
            
            if(tagItem.selectedBorderColor){
                [tagView setBorderColor: tagItem.selectedBorderColor];
            }
            
            if(vz_IsStringValid(tagItem.selectedTitle)){
                [tagView setTitle:tagItem.selectedTitle forState:UIControlStateNormal];
            }

        }else{
            VZInspectorBizLogToolBarItem *tagItem = tagView.item;
            
            if(tagItem.selectedTitleColor){
                [tagView setTextColor:tagItem.normalTitleColor];
            }
            
            if(tagItem.selectedbackgroundColor){
                [tagView setBackgroundColor:tagItem.normalBackgroundColor];
            }
            
            if(tagItem.selectedBorderColor){
                [tagView setBorderColor: tagItem.normalBorderColor];
            }
            
            if(vz_IsStringValid(tagItem.selectedTitle)){
                [tagView setTitle:tagItem.normalTitle forState:UIControlStateNormal];
            }

        }


    }
    
}

@end
