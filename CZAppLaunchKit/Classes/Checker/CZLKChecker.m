//
//  CZLKChecker.m
//  CZAppLaunchKit
//
//  Created by ChenZhen on 2022/9/22.
//

#import "CZLKChecker.h"
#import "CZLKTask.h"

#define CZLK_NOT_SEARCHED 0
#define CZLK_DID_SEARCHED -1
#define CZLK_ALL_SEARCHED 1

@implementation CZLKChecker

- (void)checkTasks:(NSArray<CZLKTask *> *)tasks {
    [self checkIsDAG:tasks];
    [self checkTaskUniqueInfo:tasks];
}

/// 检查是否为有向无环图（如果出现环，就会导致启动任务相互等待，最终导致ANR）
/// @param collection task集合
- (void)checkIsDAG:(NSArray<CZLKTask *> *)collection {
    // TODO: 优化环检测算法
    NSMapTable *map = [[NSMapTable alloc] init];
    [collection enumerateObjectsUsingBlock:^(CZLKTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [map setObject:@(CZLK_NOT_SEARCHED) forKey:obj];
    }];
    
    [collection enumerateObjectsUsingBlock:^(CZLKTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self depthFirstSearchTask:obj visited:map];
    }];
}

/// 使用DFS 确定无环
- (void)depthFirstSearchTask:(CZLKTask *)task visited:(NSMapTable *)map {
    [map setObject:@(CZLK_DID_SEARCHED) forKey:task];
    [((NSArray<CZLKTask *> *)task.dependencies) enumerateObjectsUsingBlock:^(CZLKTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int status = [[map objectForKey:obj] intValue];
        if (status == CZLK_NOT_SEARCHED) {
            [self depthFirstSearchTask:obj visited:map];
        } else if (status == CZLK_DID_SEARCHED) {
            // 出现环
            {
                *stop = YES;
                __unused NSString *error = [NSString stringWithFormat:@"[CZLK] [ERROR] 启动项依赖出错，存在环，请检查 %@ 启动项的子项", obj.tid];
                NSAssert(NO, error);
            }
        } else if (status == CZLK_ALL_SEARCHED) {
        }
    }];
    [map setObject:@(CZLK_ALL_SEARCHED) forKey:task];
}

// 检查任务info
- (void)checkTaskUniqueInfo:(NSArray<CZLKTask *> *)tasks {
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
    [tasks enumerateObjectsUsingBlock:^(CZLKTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger size = set.count;
        [set addObject:obj.tid];
        if (set.count == size) {
            *stop = YES;
            __unused NSString *errorMsg = [NSString stringWithFormat:@"[CZLK] [ERROR] 启动项重名， 请检查 %@ 是否重复定义", obj.tid];
            NSAssert(NO, errorMsg);
        }
        
        NSAssert(obj.ft.length, @"[CZLK] [ERROR] 启动项所属模块不能为空！");
        NSAssert(obj.tid.length, @"[CZLK] [ERROR] 启动项唯一ID不能为空！");
        NSAssert(obj.desc.length, @"[CZLK] [ERROR] 启动项描述不能为空！");
    }];
}
@end
