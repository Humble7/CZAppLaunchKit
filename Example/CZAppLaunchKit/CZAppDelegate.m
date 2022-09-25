//
//  CZAppDelegate.m
//  CZAppLaunchKit
//
//  Created by Humble7 on 09/22/2022.
//  Copyright (c) 2022 Humble7. All rights reserved.
//

#import "CZAppDelegate.h"
#import <CZAppLaunchKit/CZAppLaunchKit.h>
@implementation CZAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    [CZLKManager willExecuteTask:^(CZLKTask * _Nonnull task, NSDictionary * _Nonnull info) {
        NSLog(@"[CZLK] [Log] willExecuteTask %@ ", task.tid);
    }];

    [CZLKManager didExecuteTask:^(CZLKTask * _Nonnull task, NSDictionary * _Nonnull info) {
        NSLog(@"[CZLK] [Log] didExecuteTask %@ ", task.tid);
    }];

    [CZLKManager willReportTrace:^(NSMutableArray * _Nonnull events, NSMutableDictionary * _Nonnull otherData) {
        NSLog(@"[CZLK] [Log] willReportTrace \n events %@ \n otherData %@\n", events, otherData);
    }];

    CZLK_INVOKE_WILL_FINISH_LAUNCH_START_TO_END();
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // TODO: why is here view did appear?
//    [CZLKManager setAnchorTask:CZLK_ANCHOR_TASK_VIEW_DID_APPEAR_RECORD reportTrace:^(NSString * _Nonnull report, NSProgress * _Nonnull progress, NSDictionary * _Nonnull info) {
//        NSLog(@"[CZLK] [LOG] Report handler: \n %@", info);
//    }];
//    
//    [CZLKManager setFinalTask:CZLK_ANCHOR_TASK_VIEW_DID_APPEAR_RECORD finalProgress:^(NSArray * _Nonnull lefts, NSProgress * _Nonnull progress) {
//        NSLog(@"[CZLK] [LOG] Finalize handler: \n %@ \n progress %@", lefts, progress);
//    }];
//    CZLK_INVOKE_DID_FINISH_LAUNCH_START_TO_END();
    
    return YES;
}

@end
