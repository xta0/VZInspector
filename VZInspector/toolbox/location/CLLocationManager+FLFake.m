//
//  CLLocationManager+FLFake.m
//  FakeLocation
//
//  Created by John Wong on 8/2/15.
//  Copyright (c) 2015 John Wong. All rights reserved.
//

#import "CLLocationManager+FLFake.h"
#import <objc/runtime.h>
#import "VZDefine.h"
#import "FLFakeConfig.h"

@implementation CLLocationManager (FLFake)

+ (void)load {
    Method originMethod = class_getInstanceMethod([CLLocationManager class], @selector(startUpdatingLocation));
    Method swizzleMethod = class_getInstanceMethod([CLLocationManager class], @selector(fl_startUpdatingLocation));
    method_exchangeImplementations(originMethod, swizzleMethod);
}

- (void)fl_startUpdatingLocation {
    NSLog(@"Start updating location");
    FLFakeConfig *fakeConfig = [FLFakeConfig sharedInstance];
    if (fakeConfig.enabled) {
        if (self.delegate) {
            if (!fequalzero(fakeConfig.delay)) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fakeConfig.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self updateLocation:fakeConfig.location];
                });
            } else {
                [self updateLocation:fakeConfig.location];
            }
        }
    } else {
        [self fl_startUpdatingLocation];
    }
}

- (void)updateLocation:(CLLocation *)location {
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
        [self.delegate locationManager:self didUpdateLocations:@[location]];
    } else if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
        [self.delegate locationManager:self didUpdateToLocation:location fromLocation:location];
    }
}

@end
