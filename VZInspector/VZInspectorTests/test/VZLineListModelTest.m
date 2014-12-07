  
//
//  VZLineListModelTest.m
//  VZInspector
//
//  Created by Jayson on 2014-12-07 15:16:33 +0800.
//  Copyright (c) 2014年 http://akadealloc.github.io/blog. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VizzleConfig.h.h"
#import "VZLineListModel.h"

@interface VZLineListModelTest : XCTestCase

@property(nonatomic,strong)VZLineListModel* testModel;

@end

@implementation VZLineListModelTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.testModel = [VZLineListModel new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testModel {
  

    __block BOOL waitingForBlock = YES;
    [self.testModel loadWithCompletion:^(VZLineListModel *model, NSError *error) {
       
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

