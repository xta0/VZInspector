  
//
//  VZLineLogicTest.m
//  VZInspector
//
//  Created by Jayson on 2014-12-07 15:16:33 +0800.
//  Copyright (c) 2014年 http://akadealloc.github.io/blog. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VizzleConfig.h.h"
#import "VZLineLogic.h"

@interface VZLineLogicTest : XCTestCase

@property(nonatomic,strong)VZLineLogic* logic;

@end

@implementation VZLineLogicTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.logic = [ new];
    self.logic.viewController = self;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.logic = nil;
}

- (void)test_logic_view_did_load {

    [self.logic logic_view_did_load];
}

- (void)test_logic_view_will_appear
{
    [self.logic logic_view_will_appear];
}

- (void)test_logic_view_did_appear
{
    [self.logic logic_view_did_appear];
    
}

- (void)test_logic_view_will_disappear
{
    [self.logic logic_view_will_disappear];
    
}

- (void)test_logic_view_did_disappear
{
    [self.logic logic_view_did_disappear];
    
}

@end

