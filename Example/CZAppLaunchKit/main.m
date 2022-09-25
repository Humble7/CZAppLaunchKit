//
//  main.m
//  CZAppLaunchKit
//
//  Created by Humble7 on 09/22/2022.
//  Copyright (c) 2022 Humble7. All rights reserved.
//

@import UIKit;
#import <CZAppLaunchKit/CZAppLaunchKit.h>
#import "CZAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        CZLK_INVOKE_MAIN_FUNC_START_TO_END();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CZAppDelegate class]));
    }
}
