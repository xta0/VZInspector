//
//  O2OMethodTraceInputView.h
//  VZInspector
//
//  Created by lingwan on 10/29/15.
//  Copyright © 2015 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^showTraceViewBlock)(NSString *);

@interface O2OMethodTraceInputView : UIView
@property (nonatomic, copy) showTraceViewBlock showTraceViewBlock;
@end
