//
//  VZColorPanelView.m
//  APInspector
//
//  Created by pep on 2016/12/3.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZColorPanelView.h"
#import "VZColorPickerDefine.h"
#import "VZInspectorResource.h"

@interface VZColorPanelView()

@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, copy) NSArray <UILabel *> *titles;
@property (nonatomic, copy) NSArray <UILabel *> *floatValues;
@property (nonatomic, copy) NSArray <UILabel *> *hexValues; //0xee
@property (nonatomic, copy) NSArray <UILabel *> *decValues; //255
@property (nonatomic, strong) UIView *colorView;

@property (nonatomic, strong) UILabel *ratioLabel;
@property (nonatomic, strong) UISlider *ratioControl;


@end

@implementation VZColorPanelView


- (id)initWithFrame:(CGRect)frame defaultRatio:(NSInteger)defaultRatio {
    self = [super initWithFrame:frame];
    if (self) {
        self.toolBar = [[UIToolbar alloc] initWithFrame:self.bounds];
        self.toolBar.barStyle = UIBarStyleDefault;
        [self addSubview:self.toolBar];
        
        UIImageView *tipIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 20, 20)];
        tipIcon.image = [VZInspectorResource tipIcon];
        tipIcon.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.toolBar addSubview:tipIcon];
        
        CGFloat x = tipIcon.frame.origin.x + tipIcon.frame.size.width + 5;
        UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(tipIcon.frame.origin.x + tipIcon.frame.size.width + 5, tipIcon.frame.origin.y, self.toolBar.frame.size.width - x - 10, tipIcon.frame.size.height)];
        tip.adjustsFontSizeToFitWidth = YES;
        tip.text = @"拖动圆窗口、空白处滑动都可以移动焦点，幅度不同";
        tip.font = [UIFont systemFontOfSize:14];
        tip.textAlignment = NSTextAlignmentLeft;
        tip.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        tip.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self.toolBar addSubview:tip];
        
        
        CGFloat colorViewLength = 40;//边长
        CGFloat colorViewMarginLeftRight = 10;
        CGFloat labelWidth = floor((self.frame.size.width - colorViewLength - colorViewMarginLeftRight * 3) / 4.0);
        CGFloat labelHeight = 20;
        x = colorViewMarginLeftRight + colorViewLength + colorViewMarginLeftRight;
        CGFloat y = tipIcon.frame.origin.y + tipIcon.frame.size.height + 5;
        
        self.titles = [self labelsForStart:CGPointMake(x, y) labelWidth:labelWidth labelHeight:labelHeight textColor:[UIColor colorWithRed:0.98 green:0.38 blue:0.396 alpha:1]];
        [self.titles objectAtIndex:0].text = @"red";
        [self.titles objectAtIndex:1].text = @"green";
        [self.titles objectAtIndex:2].text = @"blue";
        [self.titles objectAtIndex:3].text = @"alpha";
        y += labelHeight;
        self.floatValues = [self labelsForStart:CGPointMake(x, y) labelWidth:labelWidth labelHeight:labelHeight textColor:[UIColor colorWithWhite:0.2 alpha:1]];
        y += labelHeight;
        self.hexValues = [self labelsForStart:CGPointMake(x, y) labelWidth:labelWidth labelHeight:labelHeight textColor:[UIColor colorWithWhite:0.2 alpha:1]];
        y += labelHeight;
        self.decValues = [self labelsForStart:CGPointMake(x, y) labelWidth:labelWidth labelHeight:labelHeight textColor:[UIColor colorWithWhite:0.2 alpha:1]];
        y += labelHeight;
        
        
        CGFloat infoTop = [self.titles firstObject].frame.origin.y;
        CGFloat infoBottom = [self.decValues firstObject].frame.origin.y + [self.decValues firstObject].frame.size.height;
        
        
        self.colorView = [[UIView alloc] initWithFrame:CGRectMake(colorViewMarginLeftRight, (infoTop + infoBottom - colorViewLength) * 0.5, colorViewLength, colorViewLength)];
        self.colorView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.colorView];
        
        CGFloat min = kVZCPMinZoomValue;
        CGFloat max = kVZCPMaxZoomValue;
        
        if (defaultRatio < min) {
            defaultRatio = min;
        }
        
        if (defaultRatio > max) {
            defaultRatio = max;
        }
        
        self.ratioLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.colorView.frame.origin.x, y+10, self.colorView.frame.size.width, 20)];
        self.ratioLabel.font = [UIFont systemFontOfSize:14];
        self.ratioLabel.textAlignment = NSTextAlignmentCenter;
        self.ratioLabel.textColor = [UIColor colorWithRed:0.98 green:0.38 blue:0.396 alpha:1];
        self.ratioLabel.text = [self textForRatio:defaultRatio];
        [self.toolBar addSubview:self.ratioLabel];
        
        self.ratioControl = [[UISlider alloc] initWithFrame:CGRectMake(self.ratioLabel.frame.origin.x + self.ratioLabel.frame.size.width + 5, self.ratioLabel.frame.origin.y - 3, labelWidth * 4, self.ratioLabel.frame.size.height + 6)];
        self.ratioControl.minimumValue = kVZCPMinZoomValue;
        self.ratioControl.maximumValue = kVZCPMaxZoomValue;
        self.ratioControl.value = defaultRatio;
        [self.ratioControl addTarget:self action:@selector(didSlide:) forControlEvents:UIControlEventValueChanged];
        [self.toolBar addSubview:self.ratioControl];
    }
    return self;
}

- (NSArray <UILabel *> *)labelsForStart:(CGPoint)startPoint labelWidth:(CGFloat)labelWidth labelHeight:(CGFloat)labelHeight textColor:(UIColor *)textColor {
    NSMutableArray <UILabel *> *labels = [NSMutableArray array];
    for (NSInteger i = 0 ; i < 4; ++i) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(startPoint.x + i * labelWidth, startPoint.y, labelWidth, labelHeight)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = textColor;
        [self.toolBar addSubview:label];
        [labels addObject:label];
    }
    
    return [labels copy];
}

- (NSString *)textForRatio:(NSInteger)ratio {
    return [NSString stringWithFormat:@"x%d",ratio];
}

- (void)didSlide:(id)sender {
    NSInteger ratio = floor(self.ratioControl.value + 0.5);
    if (ratio < 1) {
        ratio = 1;
    }
    
    self.ratioLabel.text = [self textForRatio:ratio];
    
    if ([self.delegate respondsToSelector:@selector(panelView:ratioDidChange:)]) {
        [self.delegate panelView:self ratioDidChange:ratio];
    }
}

- (void)updateColor:(UIColor *)color {
    if (!color) {
        return;
    }
    
    self.colorView.backgroundColor = color;
    
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    [self.floatValues objectAtIndex:0].text = [NSString stringWithFormat:@"%.3f", red];
    [self.floatValues objectAtIndex:1].text = [NSString stringWithFormat:@"%.3f", green];
    [self.floatValues objectAtIndex:2].text = [NSString stringWithFormat:@"%.3f", blue];
    [self.floatValues objectAtIndex:3].text = [NSString stringWithFormat:@"%.3f", alpha];
    
    [self.hexValues objectAtIndex:0].text = [NSString stringWithFormat:@"0x%x", (NSInteger)floor(red * 255 + 0.5)];
    [self.hexValues objectAtIndex:1].text = [NSString stringWithFormat:@"0x%x", (NSInteger)floor(green * 255 + 0.5)];
    [self.hexValues objectAtIndex:2].text = [NSString stringWithFormat:@"0x%x", (NSInteger)floor(blue * 255 + 0.5)];
    [self.hexValues objectAtIndex:3].text = [NSString stringWithFormat:@"0x%x", (NSInteger)floor(alpha * 255 + 0.5)];
    
    [self.decValues objectAtIndex:0].text = [NSString stringWithFormat:@"%d", (NSInteger)floor(red * 255 + 0.5)];
    [self.decValues objectAtIndex:1].text = [NSString stringWithFormat:@"%d", (NSInteger)floor(green * 255 + 0.5)];
    [self.decValues objectAtIndex:2].text = [NSString stringWithFormat:@"%d", (NSInteger)floor(blue * 255 + 0.5)];
    [self.decValues objectAtIndex:3].text = [NSString stringWithFormat:@"%d", (NSInteger)floor(alpha * 255 + 0.5)];
    
}

@end
