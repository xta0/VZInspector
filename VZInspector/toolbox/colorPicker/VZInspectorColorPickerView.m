//
//  VZInspectorColorPickerView.m
//  APInspector
//
//  Created by pep on 2016/12/2.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorColorPickerView.h"
#import "VZColorDisplayView.h"
#import "VZColorPanelView.h"

@interface VZInspectorColorPickerView()<VZColorDisplayViewDelegate, VZColorPanelViewDelegate>

@property(nonatomic,strong)UIButton* backBtn;
@property(nonatomic,strong)VZColorDisplayView *colorDisplayView;
@property(nonatomic,strong)VZColorPanelView *colorPanelView;

@property(nonatomic,assign) CGPoint fromPoint;
@property(nonatomic,assign) CGPoint touchFromPoint;
@property(nonatomic,assign) BOOL isMoving;
@property(nonatomic,assign) BOOL isFromCircle;//是否从圆圈开始拖动
@end


@implementation VZInspectorColorPickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame parentViewController:(UIViewController *)controller {
    self = [super initWithFrame:frame parentViewController:controller];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 44, 44)];
        self.backBtn.backgroundColor = [UIColor clearColor];
        [self.backBtn setTitle:@"<-" forState:UIControlStateNormal];
        [self.backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.backBtn addTarget:self.parentViewController action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
        [self addSubview:self.backBtn];
        
        NSUInteger defaultScale = 5;
        
        self.colorDisplayView = [VZColorDisplayView displayViewWithRadius:101 scale:defaultScale];
        self.colorDisplayView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
        self.colorDisplayView.delegate = self;
        [self addSubview:self.colorDisplayView];
        
        [self.colorDisplayView update];
        
        
        self.colorPanelView = [[VZColorPanelView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 150, self.frame.size.width, 150) defaultRatio:defaultScale];
        self.colorPanelView.delegate = self;
        [self.colorPanelView updateColor:[UIColor colorWithWhite:0.3 alpha:0.2]];
        [self addSubview:self.colorPanelView];
  
        self.multipleTouchEnabled = NO;
    }
    return self;
}

- (void)displayView:(VZColorDisplayView *)displayView colorDidUpdate:(UIColor *)color {
    [self.colorPanelView updateColor:color];
}

- (void)panelView:(VZColorPanelView *)panelView ratioDidChange:(NSInteger )ratio {
    if (ratio <= 1) {
        ratio = 1;
    }
    [self.colorDisplayView setScale:ratio];
}

- (BOOL)isTouchInDisplayView:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self];
    return CGRectContainsPoint(self.colorDisplayView.frame, touchPoint);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    do {
        if ([touches count] != 1) {
            break;
        }
        
        UITouch *touch = [touches anyObject];
        
        self.isFromCircle = [self isTouchInDisplayView:touch];
        
        self.isMoving = YES;
        self.fromPoint = self.colorDisplayView.frame.origin;
        self.touchFromPoint = [touch locationInView:self];
        return;
    } while (0);
    
    
    [super touchesBegan:touches withEvent:event];

    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (!self.isMoving) {
        return [super touchesMoved:touches withEvent:event];
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchPoint = [touch locationInView:self];
    
    CGRect frame = self.colorDisplayView.frame;
    
    CGFloat rate = self.isFromCircle ? 1 : 0.03;
    
    //整像素点
    frame.origin.x = rate * (touchPoint.x - self.touchFromPoint.x) + self.fromPoint.x;
    frame.origin.y = rate * (touchPoint.y - self.touchFromPoint.y) + self.fromPoint.y;
    
    [self updateColorDisplayViewFrame:frame];
}

- (void)updateColorDisplayViewFrame:(CGRect)frame {
    
    CGFloat scale = [[UIScreen mainScreen] scale];

    //四舍五入
    frame.origin.x = floor((frame.origin.x) * scale + 0.5) / scale;
    frame.origin.y = floor((frame.origin.y) * scale + 0.5) / scale;
    
    if (frame.origin.x < self.bounds.origin.x - frame.size.width * 0.5) {
        frame.origin.x = self.bounds.origin.x - frame.size.width * 0.5;
    }
    
    if (frame.origin.x > self.bounds.origin.x + self.bounds.size.width - frame.size.width * 0.5) {
        frame.origin.x = self.bounds.origin.x + self.bounds.size.width - frame.size.width * 0.5;
    }
    
    if (frame.origin.y < self.bounds.origin.y - frame.size.height * 0.5) {
        frame.origin.y = self.bounds.origin.y - frame.size.height * 0.5;
    }
    
    if (frame.origin.y > self.bounds.origin.y + self.bounds.size.height - frame.size.height * 0.5) {
        frame.origin.y = self.bounds.origin.y + self.bounds.size.height - frame.size.height * 0.5;
    }
    
    if (frame.origin.x != self.colorDisplayView.frame.origin.x
        || frame.origin.y != self.colorDisplayView.frame.origin.y) {
        //防止频繁刷新
        self.colorDisplayView.frame = frame;
        
        [self.colorDisplayView update];
    }
    
    
    CGRect panelDownFrame = self.colorPanelView.frame; //在下边时候的frame
    panelDownFrame.origin.y = self.frame.size.height - self.colorPanelView.frame.size.height;
    
    if (CGRectIntersectsRect(self.colorDisplayView.frame, panelDownFrame)) {
        CGRect frame = self.colorPanelView.frame;
        frame.origin.y = 0;
        self.colorPanelView.frame = frame;
        
        frame = self.backBtn.frame;
        frame.origin.y = self.colorPanelView.frame.origin.y + self.colorPanelView.frame.size.height + 10;
        self.backBtn.frame = frame;
    } else {
        self.colorPanelView.frame = panelDownFrame;
        
        CGRect frame = self.backBtn.frame;
        frame.origin.y = 0;
        self.backBtn.frame = frame;
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (!_isMoving) {
        [super touchesEnded:touches withEvent:event];
    }
    self.isMoving = NO;
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *) event {
    if (!self.isMoving) {
        [super touchesCancelled:touches withEvent:event];
    }
    self.isMoving = NO;
}

@end
