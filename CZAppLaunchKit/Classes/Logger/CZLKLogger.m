//
//  CZLKLogger.m
//  CZAppLaunchKit
//
//  Created by ChenZhen on 2022/9/22.
//

#import "CZLKLogger.h"
#import "CZLKPair.h"

#import <pthread.h>

@interface CZLKLogger ()

/// 串型队列
@property (nonatomic, strong) NSOperationQueue *queue;
/// 统计最耗时的task
@property (nonatomic, strong) NSDictionary *mostCostEvent;

/// task info list
@property (nonatomic, strong) NSMutableArray *events;

@property (nonatomic, strong) NSProgress *progress;

/// 启动项的总和
@property (nonatomic, assign) NSUInteger totalCount;

@property (nonatomic, strong) NSMutableArray *unFinishIDs;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *runtime;

@end

@implementation CZLKLogger

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        _queue.name = @"com.humble.launch.log";
        _progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        _events = [NSMutableArray array];
        _runtime = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)recordTask:(CZLKTask * _Nonnull)task execute:(os_block_t)execute {
    if (self.willExecuteHandler) {
        self.willExecuteHandler(task, nil);
    }
    
    // TODO: why 1e6 instead of 1e3
    double start = CACurrentMediaTime() * 1e6;
    execute();
    double stop = CACurrentMediaTime() * 1e6;
    
    NSDictionary *info = @{
        @"ph": @"X",
        @"name": [NSString stringWithFormat:@"%@ - %@", task.ft, task.tid],
        @"ts": [NSNumber numberWithUnsignedLongLong:(unsigned long long)start],
        @"dur": @(stop - start),
        @"tid": [self threadName],
        @"pid": [self processID],
        @"args": @{
                @"desc": task.desc,
                @"dependency": [task.dependency componentsJoinedByString:@","]
        }
    };
    if (self.didExecuteHandler) {
        self.didExecuteHandler(task, info);
    }
    
    [self.queue addOperationWithBlock:^{
        if (!self.mostCostEvent || [info[@"dur"] unsignedIntValue] > [self.mostCostEvent[@"dur"] unsignedIntValue]) {
            self.mostCostEvent = info;
        }
        [self.events addObject:info];
        self.progress.completedUnitCount = self.events.count;
        if ([self.unFinishIDs containsObject:task.tid]) {
            [self.unFinishIDs removeObject:task.tid];
        }
        if ([self shouldInvokeReport:task.tid]) {
            [self reportThisTracing];
        }
        if ([self shouldInvokeFinal:task.tid]) {
            if (self.recordFinishHandler) {
                self.recordFinishHandler(self.unFinishIDs, self.progress);
            }
        }
    }];
}

- (NSString *)threadName {
    unsigned int pid = pthread_mach_thread_np(pthread_self());
    return [NSString stringWithFormat:@"%u", pid];
}

- (NSString *)processID {
    static dispatch_once_t onceToken;
    static NSString *processID = nil;
    dispatch_once(&onceToken, ^{
        processID = [NSString stringWithFormat:@"%d", NSProcessInfo.processInfo.processIdentifier];
    });
    
    return processID;
}

- (BOOL)shouldInvokeReport:(NSString *)tid {
    if (!self.reportAnchorName) {
        return NO;
    }
    return [tid isEqualToString:self.reportAnchorName];
}

- (BOOL)shouldInvokeFinal:(NSString *)tid {
    if (!self.recordFinalName) {
        return NO;
    }
    
    return [tid isEqualToString:self.recordFinalName];
}

- (void)reportThisTracing {
    if (self.didReportHandler) {
        [self processRuntimeTaskToEvents];
        NSDictionary *traceDic = [self generateReportDictionary];
        NSString *traceJson = [self jsonReportDictionary:traceDic];
        self.didReportHandler(traceJson, self.progress, traceDic);
    }
}

- (void)processRuntimeTaskToEvents {
    for (NSString *key in self.runtime.allKeys) {
        NSMutableArray *arr = self.runtime[key];
        if (arr.count == 0) {
            NSAssert(NO, @"[CZLK] [Error] internal error.");
            continue;
        }
        if (arr.count > 0 && arr.count % 2 != 0) {
            NSAssert(NO, @"[CZLK] [Error] runtime record (start,end) not pair");
            continue;
        }
        
        NSMutableArray<CZLKPair *> *stack = [NSMutableArray arrayWithCapacity:arr.count];
        NSMutableArray<NSDictionary *> *infos = [NSMutableArray arrayWithCapacity:arr.count/2];
        
        BOOL nest = arr.count > 2;
        NSString *pid = [self processID];
        
        for (CZLKPair *pair in arr) {
            // left
            if (pair.start) {
                [stack addObject:pair];
                continue;
            }
            
            // first is right
            if (stack.count == 0) {
                NSAssert(NO, @"[CZLK] [Error] runtime record (start,end) not pair");
                break;
            }
            
            // right
            CZLKPair *start = stack.lastObject;
            CZLKPair *stop = pair;
            [stack removeLastObject];
            
            NSAssert([start.tid isEqualToString:stop.tid], @"[CZLK] [Error] runtime record start/end should be place o right position");
            
            NSString *name = nest ? [NSString stringWithFormat:@"%@_%02d", key, (unsigned int)infos.count] : key;
            [infos addObject:@{
                @"ph": @"X",
                @"name": [NSString stringWithFormat:@"CZLK_RUNTIME_PHASE - %@", name],
                @"ts": [NSNumber numberWithUnsignedLongLong:(unsigned long long)start.point],
                @"dur": @(stop.point - start.point),
                @"tid": stop.tid,
                @"pid": pid,
                @"args": @{
                        @"desc": @"",
                        @"dependency": @""
                }
            }];
        }
        if (stack.count != 0) {
            NSAssert(NO, @"[CZLK] [Error] runtime record (start,end) not pair");
            continue;
        }
        [self.events addObjectsFromArray:infos];
    }
}

- (NSDictionary *)generateReportDictionary {
    NSMutableDictionary *otherData = [self otherData];
    if (self.willReportHandler) {
        self.willReportHandler(self.events, otherData);
    }
    
    NSMutableDictionary *traceDic = [NSMutableDictionary dictionary];
#if DEBUG || INTRELEASE
    // 如果是debug或internal包，在traceDic中添加 traceEvents方便直接查看火焰图
    // 查看方式：https://ui.perfetto.dev/#!/viewer 打开上报数据的json 文件
    traceDic[@"traceEvents"] = self.events;
#endif
    
    traceDic[@"otherData"] = otherData;
    
    // 使用Key-Value类型进行上报，方便BI统计数据和后续报表制作
    NSMutableDictionary *store = [NSMutableDictionary dictionaryWithCapacity:self.events.count];
    for (NSDictionary *obj in self.events) {
        store[obj[@"name"]] = obj;
    }
    return traceDic;
}

- (NSMutableDictionary *)otherData {
    return @{
        @"total": @(self.progress.totalUnitCount),
        @"finished": @(self.progress.completedUnitCount),
        @"left": [self.unFinishIDs componentsJoinedByString:@","],
        @"dur": @([self currentDuration]),
        @"top": self.mostCostEvent,
        @"manually": NSProcessInfo.processInfo.environment[@"ActivePrewarm"] == nil ? @(1) : @(0)
    }.mutableCopy;
}

/// 当前events的总时长
- (NSUInteger)currentDuration {
    NSUInteger cost = 0;
    if (!self.events || self.events.count == 0) return cost;
    if (self.events.count == 1) {
        cost = [self.events.firstObject[@"dur"] unsignedIntValue];
    } else {
        cost = [self.events.lastObject[@"ts"] unsignedIntValue] + [self.events.lastObject[@"dur"] unsignedIntValue] - [self.events.firstObject[@"ts"] unsignedIntValue];
    }
    return cost;
}

- (NSString *)jsonReportDictionary:(NSDictionary *)traceDic {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:traceDic options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
#if DEBUG || INTRELEASE
    [self writeToDisk:jsonStr];
#endif
    return jsonStr;
}

- (void)writeToDisk:(NSString *)jsonString {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyy_MM_dd_HH_mm_ss";
    NSString *fileName = [NSString stringWithFormat:@"%@%@.json", @"czlk_", [fmt stringFromDate:[NSDate date]]];
    NSString *launchEventFilePath = [docPath stringByAppendingPathComponent:fileName];
    [jsonString writeToFile:launchEventFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)recordTask:(NSString * _Nonnull)name start:(BOOL)start {
    NSTimeInterval point = CACurrentMediaTime() * 1e6;
    NSString *tid = [self threadName];
    [self.queue addOperationWithBlock:^{
        if (!self.runtime[name]) {
            self.runtime[name] = [NSMutableArray array];
        }
        CZLKPair *pair = [[CZLKPair alloc] init];
        pair.start = start;
        pair.point = point;
        pair.tid = tid;
        [self.runtime[name] addObject:pair];
    }];
}

#pragma mark - Getter & Setter
- (void)setTasks:(NSArray<CZLKTask *> *)tasks {
    _tasks = [tasks copy];
    _totalCount = tasks.count;
    self.progress.totalUnitCount = _totalCount;
    NSMutableArray *finishArr = [NSMutableArray arrayWithCapacity:101];
    for (CZLKTask *info in tasks) {
        [finishArr addObject:info.tid];
    }
    _unFinishIDs = finishArr;
}

@end
