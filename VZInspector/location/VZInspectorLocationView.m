//
//  VZInspectorLocationView.m
//  VZInspector
//
//  Created by John Wong on 8/3/15.
//  Copyright (c) 2015 VizLab. All rights reserved.
//

#import "VZInspectorLocationView.h"
#import "FLFakeConfig.h"

@interface VZInspectorLocationView () <UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UISwitch *enableSwitch;
@property (nonatomic, strong) UITextField *latitudeText;
@property (nonatomic, strong) UITextField *longitudeText;
@property (nonatomic, strong) UISlider *delaySlider;
@property (nonatomic, strong) UILabel *delayLabel;

@end

@implementation VZInspectorLocationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 44, CGRectGetWidth(frame)-20, CGRectGetHeight(frame)-20)];
        _scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        _scrollView.layer.borderWidth = 2.0f;
        
        FLFakeConfig *fakeConfig = [FLFakeConfig sharedInstance];
        CGFloat lineHeight = 44;
        UILabel *enableLabel = [self labelWithText:@"开启" frame:CGRectMake(8, 0, 40, lineHeight)];
        [_scrollView addSubview:enableLabel];
        
        _enableSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(enableLabel.frame.origin.x + enableLabel.frame.size.width, (lineHeight - 31)/2.0, 51, 31)];
        _enableSwitch.on = fakeConfig.enabled;
        _enableSwitch.tintColor = _enableSwitch.thumbTintColor = [UIColor orangeColor];
        [_scrollView addSubview:_enableSwitch];
        
        _delayLabel = [self labelWithText:[NSString stringWithFormat:@"延迟 %@s", @(_delaySlider.value)] frame:CGRectMake(110, enableLabel.frame.origin.y, 80, lineHeight)];
        _delayLabel.text = [NSString stringWithFormat:@"延迟 %@s", @(fakeConfig.delay)];
        [_scrollView addSubview:_delayLabel];
        
        _delaySlider = [[UISlider alloc] initWithFrame:CGRectMake(_delayLabel.frame.origin.x + _delayLabel.frame.size.width, _delayLabel.frame.origin.y + (lineHeight - 31) / 2.0, 90, 31)];
        _delaySlider.maximumValue = 20;
        _delaySlider.minimumValue = 0;
        _delaySlider.value = fakeConfig.delay;
        _delaySlider.tintColor = _delaySlider.thumbTintColor = [UIColor orangeColor];
        [_scrollView addSubview:_delaySlider];
        
        UILabel *longitudeLabel = [self labelWithText:@"经度" frame:CGRectMake(enableLabel.frame.origin.x, enableLabel.frame.origin.y + enableLabel.frame.size.height, 40, lineHeight)];
        [_scrollView addSubview:longitudeLabel];
        
        CLLocationCoordinate2D coordinate = fakeConfig.location.coordinate;

        _longitudeText = [self textFieldWithText:[NSString stringWithFormat:@"%@", @(coordinate.longitude)] frame:CGRectMake(longitudeLabel.frame.origin.x + longitudeLabel.frame.size.width + 8, longitudeLabel.frame.origin.y + (lineHeight - 31) / 2.0, 90, 31)];
        [_scrollView addSubview:_longitudeText];
        
        UILabel *latitudeLabel = [self labelWithText:@"纬度" frame:CGRectMake(_scrollView.frame.size.width / 2.0 + longitudeLabel.frame.origin.x, longitudeLabel.frame.origin.y, longitudeLabel.frame.size.width, lineHeight)];
        [_scrollView addSubview:latitudeLabel];
        
        _latitudeText = [self textFieldWithText:[NSString stringWithFormat:@"%@", @(coordinate.latitude)] frame:CGRectMake(latitudeLabel.frame.origin.x + latitudeLabel.frame.size.width + 8, latitudeLabel.frame.origin.y + (lineHeight - 31) / 2.0, 90, 31)];
        [_scrollView addSubview:_latitudeText];
        
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, longitudeLabel.frame.origin.y + longitudeLabel.frame.size.height);
        [self addSubview:_scrollView];
        
        
        _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 44, 44)];
        _backBtn.backgroundColor = [UIColor clearColor];
        [_backBtn setTitle:@"<-" forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [_backBtn addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backBtn];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)didTapView:(id)sender {
    [self endEditing:YES];
}

- (void)pop
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onBack)];
#pragma clang diagnostic pop
}

- (UILabel *)labelWithText:(NSString *)text frame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont fontWithName:@"Courier-Bold" size:15];
    label.textColor = [UIColor orangeColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = text;
    return label;
}

- (UITextField *)textFieldWithText:(NSString *)text frame:(CGRect)frame {
    UITextField *label = [[UITextField alloc] initWithFrame:frame];
    label.font = [UIFont fontWithName:@"Courier-Bold" size:15];
    label.textColor = [UIColor orangeColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = text;
    label.delegate = self;
    return label;
}

@end
