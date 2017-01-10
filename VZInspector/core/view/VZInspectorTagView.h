//
//  TagView.h
//  TagObjc
//
//  Created by Javi Pulido on 16/7/15.
//  Copyright (c) 2015 Javi Pulido. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZInspectorBizLogToolBarItem.h"

@interface VZInspectorTagView : UIButton

- (instancetype) initWithTitle:(NSString *)title;

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) CGFloat paddingY;
@property (nonatomic) CGFloat paddingX;
@property (nonatomic) UIFont *textFont;

@property (nonatomic , strong) VZInspectorBizLogToolBarItem *item;

@end
