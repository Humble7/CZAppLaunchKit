//
//  CZLKTask.h
//  CZAppLaunchKit
//
//  Created by ChenZhen on 2022/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZLKTask : NSOperation

/// 启动项所属模块
@property (nonatomic, copy) NSString *ft;

/// 唯一标识ID, 不可重复，命名规则为 ft + 4位随机数字
@property (nonatomic, copy) NSString *tid;

@property (nonatomic, assign) BOOL needMainThread;

// TODO: rename 前驱
/// 注册时声明该task所依赖的其他任务ID列表
@property (nonatomic, copy) NSArray<NSString *> *dependency;

// TODO: rename 后继
/// 注册时声明该task被哪些启动项依赖
@property (nonatomic, copy) NSArray<NSString *> *premise;

/// 优先级（优先级在任务之间生效的前提是任务A和任务B不存在依赖关系。若依赖关系存在则优先级失效）
@property (nonatomic, assign) NSInteger priority;

/// 描述信息
@property (nonatomic, copy) NSString *desc;

/// 需要执行的函数逻辑
@property (nonatomic, copy) dispatch_block_t operation;

/// 需要执行的类名
@property (nonatomic, copy) NSString *clsName;

/// 需要执行的函数名
@property (nonatomic, copy) NSString *methodName;

@end

NS_ASSUME_NONNULL_END
