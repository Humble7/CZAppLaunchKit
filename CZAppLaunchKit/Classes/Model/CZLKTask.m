//
//  CZLKTask.m
//  CZAppLaunchKit
//
//  Created by ChenZhen on 2022/9/22.
//

#import "CZLKTask.h"

@interface CZLKTask ()

// 为什么要重写ready，因为在iOS 9以下不重写会遇到OOM问题
@property (nonatomic, readwrite, getter=isReady) BOOL ready;
@property (nonatomic, readwrite, getter=isExecuting) BOOL executing;
@property (nonatomic, readwrite, getter=isFinished) BOOL finished;

@end

@implementation CZLKTask

@synthesize ready = _ready;
@synthesize executing = _executing;
@synthesize finished = _finished;

- (void)start {
    @autoreleasepool {
        self.executing = YES;
        if (self.isCancelled) {
            [self done];
            return;
        }
    }
    if(self.operation) {
        self.operation();
    }
    [self done];
}

- (void)done {
    self.executing = NO;
    self.finished = YES;
}

#pragma mark - Getter & Setter
- (void)setExecuting:(BOOL)executing {
    NSString *key = @"isExecuting";
    [self willChangeValueForKey:key];
    _executing = executing;
    [self didChangeValueForKey:key];
}

- (BOOL)isExecuting {
    return _executing;
}

- (void)setFinished:(BOOL)finished {
    NSString *key = @"isFinished";
    [self willChangeValueForKey:key];
    _finished = finished;
    [self didChangeValueForKey:key];
}

- (BOOL)isFinished {
    return _finished;
}

- (void)setReady:(BOOL)ready {
    if (_ready) return;
    NSString *key = @"isReady";
    [self willChangeValueForKey:key];
    _ready = ready;
    [self didChangeValueForKey:key];
}

/// 仅当其所有依赖执行完毕后该task才ready
/// 存在主线程task依赖子线程task的情况，此时进行忙等
- (BOOL)isReady {
    if (_ready) return _ready;
    BOOL dependcyAllFinish = YES;
    for (NSOperation *operation in self.dependencies) {
        dependcyAllFinish = dependcyAllFinish && operation.isFinished;
    }
    _ready = dependcyAllFinish;
    return _ready;
}

/// 代表在非主线程时可以被子线程队列使用任意线程执行
- (BOOL)isAsynchronous {
    return !self.needMainThread;
}

- (NSString *)description {
    NSDictionary *dict = @{
        @"ft" : self.ft,
        @"tid" : self.tid,
        @"desc" : self.desc
    };
    return dict.description;
}

@end
