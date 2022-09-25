//
//  CZLKChecker.h
//  CZAppLaunchKit
//
//  Created by ChenZhen on 2022/9/22.
//

#import <Foundation/Foundation.h>

@class CZLKTask;

NS_ASSUME_NONNULL_BEGIN

@interface CZLKChecker : NSObject

/// 检查启动项是否正确
/// @param tasks 启动项集合
- (void)checkTasks:(NSArray<CZLKTask *> *)tasks;

@end

NS_ASSUME_NONNULL_END
