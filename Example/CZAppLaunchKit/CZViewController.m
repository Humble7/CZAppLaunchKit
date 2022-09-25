//
//  CZViewController.m
//  CZAppLaunchKit
//
//  Created by Humble7 on 09/22/2022.
//  Copyright (c) 2022 Humble7. All rights reserved.
//

#import "CZViewController.h"
#import <CZAppLaunchKit/CZAppLaunchKit.h>
#import <objc/runtime.h>

@interface CZViewController ()

@end

@implementation CZViewController

#pragma mark - Enable CZAPPLaunchKit

CZLK_LIFE_CYCLE_ANCHORS()

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [self runtimeTask];
//    [self nestRuntimeTask];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    CZLK_INVOKE_VIEW_DID_APPEAR_RECORD();
}

- (void)runtimeTask {
    [CZLKManager recordStartWithKey:@"TASK_NAME_A"];
    NSLog(@"TAG_TASK_A_EXECUTE");
    [CZLKManager recordEndWithKey:@"TASK_NAME_A"];
    
    [CZLKManager recordStartWithKey:@"TASK_NAME_B"];
    NSLog(@"TAG_TASK_B_EXECUTE");
    [CZLKManager recordEndWithKey:@"TASK_NAME_B"];
}

- (void)nestRuntimeTask {
    [CZLKManager recordStartWithKey:@"NEST_TASK"];
    [CZLKManager recordStartWithKey:@"NEST_TASK"];
    NSLog(@"TAG_NEST_TASK_EXECUTE");
    [CZLKManager recordEndWithKey:@"NEST_TASK"];
    [CZLKManager recordEndWithKey:@"NEST_TASK"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
