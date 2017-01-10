//
//  FLFakeConfig.m
//  FakeLocation
//
//  Created by John Wong on 8/2/15.
//  Copyright (c) 2015 John Wong. All rights reserved.
//

#import "FLFakeConfig.h"
#import "VZDefine.h"

@interface FLFakeConfig ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

static NSString * const kFLEnable = @"FLEnable";
static NSString * const kFLLatitude = @"FLLatitude";
static NSString * const kFLLongitude = @"FLLongitude";
static NSString * const kFLDelay = @"FLDelay";

@implementation FLFakeConfig

+ (instancetype)sharedInstance {
    static FLFakeConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _userDefaults = [[NSUserDefaults alloc]initWithUser:@"com.johnwong.FakeLocation"];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    [_userDefaults setValue:@(enabled) forKey:kFLEnable];
    [_userDefaults synchronize];
}

- (void)setLatitude:(CLLocationDegrees)latitude {
    [_userDefaults setValue:@(latitude) forKey:kFLLatitude];
    [_userDefaults synchronize];
}

- (void)setLongitude:(CLLocationDegrees)longitude {
    [_userDefaults setValue:@(longitude) forKey:kFLLongitude];
    [_userDefaults synchronize];
}

- (void)setDelay:(CFTimeInterval)delay {
    [_userDefaults setValue:@(delay) forKey:kFLDelay];
    [_userDefaults synchronize];
}

- (BOOL)enabled {
    id value = [_userDefaults valueForKey:kFLEnable];
    return value? [value boolValue] : NO;
}

- (CLLocation *)location {
    CLLocationDegrees latitude = [[_userDefaults valueForKey:kFLLatitude] doubleValue];
    CLLocationDegrees longitude = [[_userDefaults valueForKey:kFLLongitude] doubleValue];
    if (fequalzero(latitude) && fequalzero(longitude)) {
        latitude = 30.26667;
        longitude = 120.2;
    }
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (CFTimeInterval)delay {
    return [[_userDefaults valueForKey:kFLDelay] doubleValue];
}

@end
