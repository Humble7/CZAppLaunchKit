//
//  CZLKManager.m
//  Pods
//
//  Created by ChenZhen on 2022/9/22.
//

#import "CZLKManager.h"
#import "CZLKGenerator.h"
#import "CZLKChecker.h"
#import "CZLKLogger.h"
#import "CZLKTask.h"
#import "CZLKExecutor.h"

static NSString *runtimeGenerator;
static CZLKManager *instance;

@interface CZLKManager ()

@property (nonatomic, strong) CZLKGenerator *generator;
@property (nonatomic, strong) CZLKChecker *checker;
@property (nonatomic, strong) CZLKLogger *logger;
@property (nonatomic, copy) NSArray<CZLKTask *> *tasks;

@end

@implementation CZLKManager

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CZLKManager alloc] init];
        [instance initModules];
    });
    return instance;
}

- (void)initModules {
    if (runtimeGenerator) {
        // TODO: figure out
        _generator = [[NSClassFromString(@"MainProjectLKCodeGenerator") alloc] init];
    } else {
        _generator = [[CZLKGenerator alloc] init];
        _checker = [[CZLKChecker alloc] init];
    }
    _logger = [[CZLKLogger alloc] init];
    
    // 传入logger记录task执行信息
    [_generator setLogger:_logger];
    
    NSTimeInterval start = CACurrentMediaTime();
    NSArray<CZLKTask *> *tasks = [self.generator generateTasks];
    
    _logger.tasks = tasks;
    [_checker checkTasks:tasks];
    self.tasks = tasks;
    
    NSTimeInterval stop = CACurrentMediaTime();
    NSLog(@"[CZLK] get all tasks ready take %f ms", (stop - start) * 1e3);
}

+ (void)executeTask:(NSString *)task {
    NSAssert(CZLKManager.shared, @"[CZLK] [Error] - CZLKManager already released");
    [CZLKManager.shared executeTask:task];
}

- (void)executeTask:(NSString *)task {
    CZLKExecutor *executor = [[CZLKExecutor alloc] init];
    executor.tasks = self.tasks;
    [executor executeTask:task];
}

+ (void)executeTasksFrom:(NSString *)start to:(NSString *)end {
    NSAssert(CZLKManager.shared, @"[CZLK] [Error] - CZLKManager already released");
    [CZLKManager.shared executeFrom:start to:end];
}

- (void)executeFrom:(NSString *)taskStart to:(NSString *)taskEnd {
    CZLKExecutor *executor = [[CZLKExecutor alloc] init];
    executor.tasks = self.tasks;
    [executor executeFrom:taskStart to:taskEnd];
}

+ (void)willExecuteTask:(CZLKTaskExecuteBlock)block {
    NSAssert(CZLKManager.shared, @"[CZLK] [ERROR] - CZLKManager already released");
    CZLKManager.shared.logger.willExecuteHandler = block;
}

+ (void)didExecuteTask:(CZLKTaskExecuteBlock)block {
    NSAssert(CZLKManager.shared, @"[CZLK] [ERROR] - CZLKManager already released");
    CZLKManager.shared.logger.didExecuteHandler = block;
}

+ (void)willReportTrace:(CZLKReportModifyBlock)block {
    NSAssert(CZLKManager.shared, @"[CZLK] [ERROR] - CZLKManager already released");
    CZLKManager.shared.logger.willReportHandler = block;
}

+ (void)setAnchorTask:(NSString *)name reportTrace:(CZLKReportInvokeBlock)block {
    NSAssert(CZLKManager.shared, @"[CZLK] [ERROR] - CZLKManager already released");
    CZLKManager.shared.logger.didReportHandler = block;
    CZLKManager.shared.logger.reportAnchorName = name;
}

+ (void)setFinalTask:(NSString *)name finalProgress:(CZLKFinalInvokeBlock)block {
    NSAssert(CZLKManager.shared, @"[CZLK] [ERROR] - CZLKManager already released");
    CZLKManager.shared.logger.recordFinishHandler = ^(NSArray * _Nonnull lefts, NSProgress * _Nonnull progress) {
        [CZLKManager finish];
        if (block) {
            block(lefts, progress);
        }
    };
    CZLKManager.shared.logger.recordFinalName = name;
}

/// 启动任务全部执行完成，并且上报处理完成后进行释放
+ (void)finish {
    instance = nil;
    NSLog(@"[CZLK] [LOG] CZLKManager has released");
}

+ (void)recordStartWithKey:(NSString *)key {
    NSAssert(CZLKManager.shared, @"[CZLK] [ERROR] - CZLKManager already released");
    [CZLKManager.shared.logger recordTask:key start:YES];
}

+ (void)recordEndWithKey:(NSString *)key {
    NSAssert(CZLKManager.shared, @"[CZLK] [ERROR] - CZLKManager already released");
    [CZLKManager.shared.logger recordTask:key start:NO];
}

+ (void)runtimeGeneratorFromOutside:(NSString *)name {
    runtimeGenerator = name;
}

@end
