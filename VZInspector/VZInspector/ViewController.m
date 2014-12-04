//
//  ViewController.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import "ViewController.h"
#import "VZHeapInspector.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [VZHeapInspector trackObjectsWithPrefix:@"VZ"];
    NSSet* set = [VZHeapInspector livingObjectsWithPrefix];
    NSLog(@"%@",set);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
