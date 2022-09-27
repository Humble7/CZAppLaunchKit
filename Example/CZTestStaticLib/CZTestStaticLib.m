//
//  CZTestStaticLib.m
//  CZTestStaticLib
//
//  Created by ChenZhen on 2022/9/27.
//  Copyright © 2022 Humble7. All rights reserved.
//

#import "CZTestStaticLib.h"
#import "CZLKDefine.h"

// 在主工程中引入静态库后，记得配置主工程的target,在build setting -> other Linker flags 添加'-ObjC'
CZLK_THIRD_SDK_MAIN_TASK(THIRD_SDK_MAIN_Static_001, "THIRD_SDK_MAIN_Static_001") {
    NSLog(@"[Test]THIRD_SDK_MAIN_Static_001");
}

@implementation CZTestStaticLib

@end
