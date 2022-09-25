//
//  CZLKExecutor.h
//  CZAppLaunchKit
//
//  Created by ChenZhen on 2022/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CZLKTask;

@interface CZLKExecutor : NSObject

@property (nonatomic, copy) NSArray<CZLKTask *> *tasks;

/// 执行一个无依赖的启动项
/// @param task name
- (void)executeTask:(NSString *)task;

/// 执行两个任务之间的所有任务
/// @param taskStart 开始任务
/// @param taskEnd 结束任务
- (void)executeFrom:(NSString *)taskStart to:(NSString *)taskEnd;

@end

NS_ASSUME_NONNULL_END
