//
//  CZLKManager.h
//  Pods
//
//  Created by ChenZhen on 2022/9/22.
//

#import <Foundation/Foundation.h>
#import "CZLKLogger.h"
NS_ASSUME_NONNULL_BEGIN

/// Extra logic of standard operation
/// @param entry "File Entry" from "Executable File" Data segment
/// @param operation Standard operation of time-record.
typedef void (^CZLKCustomExecuteBlock) (struct CZLKEntry entry, dispatch_block_t _Nonnull operation);

@interface CZLKManager : NSObject

@property (nonatomic, copy) CZLKCustomExecuteBlock customExecute;

+ (instancetype)shared;

/// Execute tasks from start to end
/// @param start task name string
/// @param end task name string
+ (void)executeTasksFrom:(NSString *)start to:(NSString *)end;

/// Execute a single task
+ (void)executeTask:(NSString *)task;

/// Handler for single task start
/// @param block parameters is readonly, info is nil
+ (void)willExecuteTask:(CZLKTaskExecuteBlock)block;

/// Handler for single task finish
/// @param block parameter is readonly.
+ (void)didExecuteTask:(CZLKTaskExecuteBlock)block;

/// Handler for modify trace dictionary for adding information
/// @param block parameters should be inout, not replace it.
+ (void)willReportTrace:(CZLKReportModifyBlock)block;

/// Set a anchor task invoke report
/// @param name anchor task name
/// @param block json is a serial data of info
+ (void)setAnchorTask:(NSString *)name reportTrace:(CZLKReportInvokeBlock)block;

/// Set a anchor task invoke report
/// @param name anchor task name
+ (void)setFinalTask:(NSString *)name finalProgress:(CZLKFinalInvokeBlock)block;

/// Tag a single task start on runtime, should use 'recordEndWithKey:' as pair
/// This function could be use in nest like
///
/// [CZLKManager recordStartWithKey:@"TAG_TASK_NAME"];
/// [CZLKManager recordStartWithKey:@"TAG_TASK_NAME"];
/// NSLog(@"TAG_TASK_EXECUTE");
/// [CZLKManager recordEndWithKey:@"TAG_TASK_NAME"];
/// [CZLKManager recordEndWithKey:@"TAG_TASK_NAME"];
/// @param key task name, use TASK_NAME principle will be better
+ (void)recordStartWithKey:(NSString *)key;
+ (void)recordEndWithKey:(NSString *)key;

// TODO: confused the use of this func.
/// 用于第一版代码生成CZAutoCodeEnable使用 【警告：谨慎使用】
/// @param name 主工程应使用MainProjectLKCodeGenerator
+ (void)runtimeGeneratorFromOutside:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
