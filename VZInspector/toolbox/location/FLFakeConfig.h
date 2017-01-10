//
//  FLFakeConfig.h
//  FakeLocation
//
//  Created by John Wong on 8/2/15.
//  Copyright (c) 2015 John Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface  FLFakeConfig : NSObject

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, assign) CFTimeInterval delay;

- (void)setLatitude:(CLLocationDegrees)latitude;
- (void)setLongitude:(CLLocationDegrees)longitude;

+ (instancetype)sharedInstance;

@end
