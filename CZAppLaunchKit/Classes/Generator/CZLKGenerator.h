//
//  CZLKGenerator.h
//  CZAppLaunchKit
//
//  Created by ChenZhen on 2022/9/22.
//

#import <Foundation/Foundation.h>

@class CZLKLogger;
@class CZLKTask;
NS_ASSUME_NONNULL_BEGIN

@interface CZLKGenerator : NSObject
@property (nonatomic, strong) CZLKLogger *logger;

/// 获取生成启动项的集合
- (NSArray<CZLKTask *> *)generateTasks;
@end

NS_ASSUME_NONNULL_END
