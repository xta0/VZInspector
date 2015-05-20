//
//  VZInspectorSubView.h
//  VZInspector
//
//  Created by moxin on 15/5/20.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZInspectorHeapSubView : UIView
{
@protected
    id _obj;
}
@property(nonatomic,weak) id delegate;
@property(nonatomic,strong) NSString* title;

- (id)initWithFrame:(CGRect)frame data:(id)obj;

@end
