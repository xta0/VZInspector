  
//
//  VLLineListModelTest.m
//  VZListExample
//
//  Created by Jayson on 2014-12-07 16:10:56 +0800.
//  Copyright (c) 2014年 VizLab: http://vizlab.com. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VizzleConfig.h"
#import "VLLineListModel.h"

@interface VLLineListModelTest : XCTestCase

@property(nonatomic,strong)VLLineListModel* model;

@end

@implementation VLLineListModelTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.model = [VLLineListModel new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testModel {
  

    __block BOOL waitingForBlock = YES;
    [self.model loadWithCompletion:^(VZModel *model, NSError *error) {
       
      //todo...
      //add some test logic here

        XCTAssert(!error, @"Pass");
        waitingForBlock = NO;
        
    }];
    
    while (waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

@end

