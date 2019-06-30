//
//  Copyright © 2016年 Vizlab. All rights reserved.
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
