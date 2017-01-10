//
//  VZInspectorLocationView.m
//  VZInspector
//
//  Created by John Wong on 8/3/15.
//  Copyright (c) 2015 VizLab. All rights reserved.
//

#import "VZInspectorLocationView.h"
#import "FLFakeConfig.h"

@interface VZLocationItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

@end

@implementation VZLocationItem

static NSString * const kCity = @"city";
static NSString * const kLatitude = @"latitude";
static NSString * const kLongitude = @"longitude";

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _city = [aDecoder decodeObjectForKey:kCity];
        _latitude = [[aDecoder decodeObjectForKey:kLatitude] doubleValue];
        _longitude = [[aDecoder decodeObjectForKey:kLongitude] doubleValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_city forKey:kCity];
    [aCoder encodeObject:@(_latitude) forKey:kLatitude];
    [aCoder encodeObject:@(_longitude) forKey:kLongitude];
}

- (instancetype)initWithCity:(NSString *)city latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    self = [super init];
    if (self) {
        _city = city;
        _latitude = latitude;
        _longitude = longitude;
    }
    return self;
}

@end

@interface VZInspectorLocationView () <UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UISwitch *enableSwitch;
@property (nonatomic, strong) UITextField *latitudeText;
@property (nonatomic, strong) UITextField *longitudeText;
@property (nonatomic, strong) UISlider *delaySlider;
@property (nonatomic, strong) UILabel *delayLabel;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation VZInspectorLocationView

static NSString * const kFLLocationList = @"FLLocationList";
static NSInteger const kCityTagBase = 2000;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 13, frame.size.width, 18)];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = [UIFont systemFontOfSize:18.0f];
        textLabel.text = @"Fake Location";
        [self addSubview:textLabel];
        
        self.backgroundColor = [UIColor clearColor];
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 44, CGRectGetWidth(frame)-20, CGRectGetHeight(frame)-20)];
        _scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        _scrollView.layer.borderWidth = 2.0f;
        
        [self setupScrollView];
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

- (void)setupScrollView {
    [_scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    FLFakeConfig *fakeConfig = [FLFakeConfig sharedInstance];
    CGFloat lineHeight = 44;
    UILabel *enableLabel = [self labelWithText:@"开启" frame:CGRectMake(8, 0, 36, lineHeight)];
    [_scrollView addSubview:enableLabel];
    
    _enableSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(enableLabel.frame.origin.x + enableLabel.frame.size.width, (lineHeight - 31)/2.0, 51, 31)];
    _enableSwitch.on = fakeConfig.enabled;
    _enableSwitch.tintColor = _enableSwitch.thumbTintColor = [UIColor orangeColor];
    [_enableSwitch addTarget:self action:@selector(switchValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [_scrollView addSubview:_enableSwitch];
    
    _delayLabel = [self labelWithText:[NSString stringWithFormat:@"延迟%@s", @(fakeConfig.delay)] frame:CGRectMake(105, enableLabel.frame.origin.y, 90, lineHeight)];
    [_scrollView addSubview:_delayLabel];
    
    _delaySlider = [[UISlider alloc] initWithFrame:CGRectMake(_delayLabel.frame.origin.x + _delayLabel.frame.size.width, _delayLabel.frame.origin.y + (lineHeight - 31) / 2.0, 100, 31)];
    _delaySlider.maximumValue = 20;
    _delaySlider.minimumValue = 0;
    _delaySlider.value = fakeConfig.delay;
    _delaySlider.tintColor = _delaySlider.thumbTintColor = [UIColor orangeColor];
    [_delaySlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [_scrollView addSubview:_delaySlider];
    
    UILabel *latitudeLabel = [self labelWithText:@"纬度" frame:CGRectMake(enableLabel.frame.origin.x, enableLabel.frame.origin.y + enableLabel.frame.size.height, 30, lineHeight)];
    [_scrollView addSubview:latitudeLabel];
    
    CLLocationCoordinate2D coordinate = fakeConfig.location.coordinate;
    
    _latitudeText = [self textFieldWithText:[NSString stringWithFormat:@"%@", @(coordinate.latitude)] frame:CGRectMake(latitudeLabel.frame.origin.x + latitudeLabel.frame.size.width + 8, latitudeLabel.frame.origin.y + (lineHeight - 31) / 2.0, 90, 31)];
    [_latitudeText addTarget:self action:@selector(textFieldDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [_scrollView addSubview:_latitudeText];
    
    UILabel *longitudeLabel = [self labelWithText:@"经度" frame:CGRectMake(_scrollView.frame.size.width / 2.0 + latitudeLabel.frame.origin.x, latitudeLabel.frame.origin.y, latitudeLabel.frame.size.width, lineHeight)];
    [_scrollView addSubview:longitudeLabel];
    
    _longitudeText = [self textFieldWithText:[NSString stringWithFormat:@"%@", @(coordinate.longitude)] frame:CGRectMake(longitudeLabel.frame.origin.x + longitudeLabel.frame.size.width + 8, longitudeLabel.frame.origin.y + (lineHeight - 31) / 2.0, 90, 31)];
    [_longitudeText addTarget:self action:@selector(textFieldDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [_scrollView addSubview:_longitudeText];
    
    __block CGFloat top = _latitudeText.frame.origin.y + _latitudeText.frame.size.height + 8;
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, top, _scrollView.frame.size.width, 1)];
    top += 8;
    sep.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
    [_scrollView addSubview:sep];
    
    [[self locationList] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        VZLocationItem *item = obj;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(8, top, _scrollView.frame.size.width - 8 * 2, lineHeight)];
        top = top + lineHeight;
        btn.titleLabel.font = [UIFont fontWithName:@"Courier-Bold" size:15];
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [btn setTitle:[NSString stringWithFormat:@"%@   %@, %@", item.city, @(item.latitude), @(item.longitude)] forState:UIControlStateNormal];
        btn.tag = kCityTagBase + idx;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn addTarget:self action:@selector(selectConfig:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:btn];
        
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, top);
}

- (NSArray *)locationList {
    NSArray *locations = [[NSUserDefaults standardUserDefaults] objectForKey:kFLLocationList];
    if (!locations) {
        locations = [NSArray array];
    }
    locations = [locations arrayByAddingObjectsFromArray:
                 @[
                   [[VZLocationItem alloc] initWithCity:@"杭州" latitude:30.26667 longitude:120.2],
                   [[VZLocationItem alloc] initWithCity:@"北京" latitude:39.9 longitude:116.3833],
                   [[VZLocationItem alloc] initWithCity:@"上海" latitude:31.24 longitude:121.47],
                   [[VZLocationItem alloc] initWithCity:@"广州" latitude:23.18 longitude:113.28],
                   [[VZLocationItem alloc] initWithCity:@"石家庄" latitude:38.03 longitude:114.48],
                   [[VZLocationItem alloc] initWithCity:@"西安" latitude:34.27 longitude:108.95],
                   [[VZLocationItem alloc] initWithCity:@"富阳" latitude:30.07 longitude:119.95],
                   [[VZLocationItem alloc] initWithCity:@"奥克兰（新西兰）" latitude:36.83 longitude:174.73],
                   [[VZLocationItem alloc] initWithCity:@"纽约" latitude:40.67 longitude:73.94],
                   [[VZLocationItem alloc] initWithCity:@"东京" latitude:35.7 longitude:139.7],
                   [[VZLocationItem alloc] initWithCity:@"纽约" latitude:40.67 longitude:73.94]
                   ]];
    return locations;
}

- (void)selectConfig:(UIButton *)sender {
    NSInteger index = sender.tag - kCityTagBase;
    VZLocationItem *item = [self locationList][index];
    FLFakeConfig *config = [FLFakeConfig sharedInstance];
    [config setLatitude:item.latitude];
    [config setLongitude:item.longitude];
    if (!config.enabled) {
        [config setEnabled:YES];
    }
    [self setupScrollView];
}

- (void)didTapView:(id)sender {
    [self endEditing:YES];
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
    label.backgroundColor = [UIColor whiteColor];
    label.layer.borderWidth = 1;
    label.layer.cornerRadius = 5;
    label.layer.borderColor = [UIColor grayColor].CGColor;
    label.text = text;
    label.delegate = self;
    return label;
}

- (void)switchValueDidChange:(UISwitch *)sender {
    [FLFakeConfig sharedInstance].enabled = sender.isOn;
}

- (void)sliderValueDidChange:(UISlider *)sender {
    [FLFakeConfig sharedInstance].delay = sender.value;
    _delayLabel.text = [NSString stringWithFormat:@"延迟%@s", @(sender.value)];
}

- (void)textFieldDidEnd:(UITextField *)sender {
    FLFakeConfig *fakeConfig = [FLFakeConfig sharedInstance];
    double value = [sender.text doubleValue];
    if (sender == _latitudeText) {
        [fakeConfig setLatitude:value];
    } else if (sender == _longitudeText) {
        [fakeConfig setLongitude:value];
    }
}

@end
