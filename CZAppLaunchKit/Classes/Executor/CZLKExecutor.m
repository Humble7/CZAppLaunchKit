//
//  CZLKExecutor.m
//  CZAppLaunchKit
//
//  Created by ChenZhen on 2022/9/22.
//

#import "CZLKExecutor.h"
#import "CZLKTask.h"

@interface CZLKExecutor ()
@property (nonatomic, strong) NSOperationQueue *asyncQueue;
@end

@implementation CZLKExecutor

/// 执行一个无依赖的启动项
/// 原理和from:to: 是一样的
- (void)executeTask:(NSString *)task {
    [self executeFrom:nil to:task];
}

- (void)executeFrom:(NSString *)taskStart to:(NSString *)taskEnd {
    [self executeOnMainFrom:taskStart to:taskEnd];
}

/// 执行两个任务之间的所有任务（主线程执行）
// TODO: taskStart never be used.
- (void)executeOnMainFrom:(NSString *)taskStart to:(NSString *)taskEnd {
    // 从尾部结点一直往前寻找
    CZLKTask *endItem = [self findTaskByName:taskEnd];
    NSAssert(endItem, @"[CZLK] [ERROR] %@ 未找到", endItem.name);
    
    NSMutableSet *tempSet = [NSMutableSet set];
    NSMutableSet *taskSet = [NSMutableSet set];
    
    [tempSet addObject:endItem];
    
    while (tempSet.count > 0) {
        CZLKTask *curTask = [tempSet anyObject];
        if (!curTask) break;
        [taskSet addObject:curTask];
        [tempSet removeObject:curTask];
        [tempSet addObjectsFromArray:curTask.dependencies];
        [curTask.premise enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // 反向依赖注册的启动项通过这里添加
            // 如果任务队列中已经存在，那么就不添加
            CZLKTask *item = [self findTaskByName:obj];
            [taskSet containsObject:item] ?: [tempSet addObject:item];
        }];
    }
    
    // 需要主线程执行
    NSSet *mainTaskSet = [taskSet objectsPassingTest:^BOOL(CZLKTask *  _Nonnull obj, BOOL * _Nonnull stop) {
        return [obj needMainThread] &&
        !obj.isFinished &&
        !obj.isExecuting &&
        ![NSOperationQueue.mainQueue.operations containsObject:obj];
    }];
    
    // 需要子线程执行
    NSSet *backgroundTaskSet = [taskSet objectsPassingTest:^BOOL(CZLKTask *  _Nonnull obj, BOOL * _Nonnull stop) {
        return ![obj needMainThread] &&
        !obj.isFinished &&
        !obj.isExecuting &&
        ![self.asyncQueue.operations containsObject:obj];
    }];
    
    [self.asyncQueue addOperations:backgroundTaskSet.allObjects waitUntilFinished:NO];
    [self executeTasksOnMain:mainTaskSet.allObjects];
}

- (CZLKTask *)findTaskByName:(NSString *)name {
    __block CZLKTask *result = nil;
    [self.tasks enumerateObjectsUsingBlock:^(CZLKTask  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.tid isEqualToString:name]) {
            result = obj;
            *stop = YES;
        }
    }];
    
    NSAssert(result, @"[CZLK] [ERROR] 根据task id %@ 无法找到任务", name);
    return result;
}

- (void)executeTasksOnMain:(NSArray<CZLKTask *> *)tasks {
    NSBlockOperation *task = [NSBlockOperation blockOperationWithBlock:^{
        // 这里的思路是：
        // 先直接把全部ready的任务执行完毕
        // 剩下没有read的任务其中一定有对子线程任务的依赖，而且肯定是将要执行的第一个主线程任务的依赖
        // 等待依赖任务返回后再次执行所有read的任务，知道剩下的task数组全部执行完毕
        
        // 执行所有可以执行的task，返回还没有ready的
        NSArray<CZLKTask *> *notReadyList = executeAllTaskWhenItShouldBeExecuted(tasks);
        while (notReadyList && (notReadyList.count > 0)) {
            // 从这里filter出的条件是该task所有依赖中仅需要等待子线程任务返回的主线程任务
            NSArray *itemJustWaitForBgTasks = filterCZLKTasksBy(notReadyList, ^BOOL(CZLKTask *item) {
                return taskJustDependOnBgTasks(item);
            });
            
            for (CZLKTask *item in itemJustWaitForBgTasks) {
                // 过滤出可执行的，被依赖的子线程任务
                NSArray *depBgTasks = filterCZLKTasksBy((NSArray <CZLKTask *> *)item.dependencies, ^BOOL(CZLKTask *filterItem) {
                    return !filterItem.needMainThread && !filterItem.isFinished;
                });
                for (CZLKTask *dep in depBgTasks) {
                    [dep waitUntilFinished];
                }
                // 到这里该主线程任务的子线程依赖全部完成，再将主线程可执行任务执行一遍
                notReadyList = executeAllTaskWhenItShouldBeExecuted(notReadyList);
            }
        }
    }];
    
    // 主线程任务必须在主线程执行
    NSThread.isMainThread ? [task main] : [NSOperationQueue.mainQueue addOperation:task];
}

# pragma mark - Private

/// 执行所有可以执行的启动任务，并返回所有不能执行的任务
/// @param tasks 启动任务列表
static NSArray<CZLKTask *> * executeAllTaskWhenItShouldBeExecuted(NSArray<CZLKTask *> *tasks) {
    NSArray<CZLKTask *> *readyList = filterCZLKTasksBy(tasks, ^BOOL(CZLKTask *item) {
        return !item.isFinished && item.isReady;
    });
    
    // comparator 按照优先级排序
    NSComparator comparator = ^NSComparisonResult(CZLKTask *obj1, CZLKTask *obj2) {
        // TODO: should be return NSComparisonResult, instead of bool?
        return obj1.priority < obj2.priority;
    };
    
    while (readyList && (readyList.count > 0)) {
        // 每次执行主线程逻辑到这里先按照优先级进行排序，
        // 必须保证主线程优先级可用，因为是我们自己调度的
        readyList = [readyList sortedArrayUsingComparator:comparator];
        
        for (CZLKTask *task in readyList) {
            [task start];
        }
        readyList = filterCZLKTasksBy(tasks, ^BOOL(CZLKTask *item) {
            return !item.finished && item.isReady;
        });
    }
    
    return filterCZLKTasksBy(tasks, ^BOOL(CZLKTask *item) {
        return !item.isFinished && !item.isReady;
    });
}

/// 检查是否一个task目前未完成的状态只由子线程任务导致
/// 使用递归循环查找到根结点
/// @param task 检查的task结点
BOOL taskJustDependOnBgTasks(CZLKTask *task) {
    if (!task) return NO;
    BOOL state = YES;
    for (CZLKTask *dep in task.dependencies) {
        if (dep.isFinished) continue;
        if (dep.needMainThread) return NO;
        state = state && taskJustDependOnBgTasks(dep);
        if (!state) break;
    }
    return state;
}

static NSArray<CZLKTask *> * filterCZLKTasksBy(NSArray<CZLKTask *> *tasks, BOOL (^filter) (CZLKTask *task)) {
    if (tasks.count == 0) return @[];
    NSMutableArray<CZLKTask *> *result = [NSMutableArray arrayWithCapacity:tasks.count];
    for (CZLKTask *task in tasks) {
        BOOL keep = filter(task);
        if (keep) {
            [result addObject:task];
        }
    }
    return result.copy;
}

- (NSOperationQueue *)asyncQueue {
    if (!_asyncQueue) {
        _asyncQueue = [[NSOperationQueue alloc] init];
        _asyncQueue.maxConcurrentOperationCount = [NSProcessInfo processInfo].activeProcessorCount;
        _asyncQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        _asyncQueue.name = @"com.humble.launch.async";
    }
    return _asyncQueue;
}

@end
