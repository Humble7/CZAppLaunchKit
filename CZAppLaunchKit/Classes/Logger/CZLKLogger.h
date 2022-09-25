//
//  CZLKLogger.h
//  CZAppLaunchKit
//
//  Created by ChenZhen on 2022/9/22.
//

#import <Foundation/Foundation.h>
#import "CZLKTask.h"

NS_ASSUME_NONNULL_BEGIN

/// Block for single task
/// @param task task will & did execute
/// @param info of single task can be presented on 'https://ui.perfetto.dev/#!/viewer' or 'chrome://tracing.data' 
typedef void (^CZLKTaskExecuteBlock) (CZLKTask * _Nonnull task, NSDictionary * _Nullable info);

/// Block for modify before report
/// @param events all chrome:tracing data from begin to anchor
/// @param otherData calculate result from events
typedef void (^CZLKReportModifyBlock) (NSMutableArray * _Nonnull events, NSMutableDictionary * _Nonnull otherData);

/// Block for report
/// @param report all chrome:tracing data from begin to anchor
/// @param info source dictionary of report
typedef void (^CZLKReportInvokeBlock) (NSString * _Nonnull report, NSProgress * _Nonnull progress, NSDictionary * _Nonnull info);

/// Block for report
/// @param lefts tasks not be executed
/// @param progress complete state
typedef void (^CZLKFinalInvokeBlock) (NSArray * _Nonnull lefts, NSProgress * _Nonnull progress);

@interface CZLKLogger : NSObject

@property (nonatomic, copy) NSArray<CZLKTask *> *tasks;
/// Task should invoke reportHandler
@property (nonatomic, copy) NSString *reportAnchorName;
/// Task should invoke recordFinishHandler
@property (nonatomic, copy) NSString *recordFinalName;

/// Handler before Mach-O entry func point execute
@property (nonatomic, copy) CZLKTaskExecuteBlock willExecuteHandler;
/// Handler after Mach-O entry func point execute
@property (nonatomic, copy) CZLKTaskExecuteBlock didExecuteHandler;
/// Handler when tasks executed anchor task and prepare report
@property (nonatomic, copy) CZLKReportModifyBlock willReportHandler;
/// Handler when tasks executed anchor task and do report
@property (nonatomic, copy) CZLKReportInvokeBlock didReportHandler;
/// Handler when tasks executed anchor task and do report
@property (nonatomic, copy) CZLKFinalInvokeBlock recordFinishHandler;

/// Record task should be executed
/// @param task which should be recorded
/// @param execute invoke the task source entry func pointer, refer to CZLKGenerator
- (void)recordTask:(CZLKTask * _Nonnull)task execute:(os_block_t)execute;

/// Record runtime tag with pairs
/// @param name task name
/// @param start is called by 'recordStartWithKey:'
- (void)recordTask:(NSString * _Nonnull)name start:(BOOL)start;

@end

NS_ASSUME_NONNULL_END
