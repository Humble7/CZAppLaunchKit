//
//  CZLKGenerator.m
//  CZAppLaunchKit
//
//  Created by ChenZhen on 2022/9/22.
//

#import "CZLKGenerator.h"
#import "CZLKTask.h"
#import "CZLKMacros.h"
#import "CZLKTask.h"
#import "CZLKLogger.h"
#import "CZLKManager.h"

#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <dlfcn.h>

#define CZLKPriorityVeryHigh INT_MAX
#define CZLKPriorityHigh 1024
#define CZLKPriorityDefault 0
#define CZLKPriorityLow -1024
#define CZLKPriorityVeryLow INT_MIN


#ifdef __LP64__ /* Long and Pointer are 64-bit */

typedef uint64_t CZLKExportValue;
typedef struct mach_header_64 mach_header_t;
typedef struct section_64 CZLKExportSection;

#define CZLKGetSectByNameFromHeader getsectbynamefromheader_64


#else

typedef uint32_t CZLKExportValue;
typedef struct section CZLKExportSection;
typedef struct mach_header mach_header_t;

#define CZLKGetSectByNameFromHeader getsectbynamefromheader

#endif

static NSArray<NSString *> *czlk_dependenciesfromString(char *string) {
    if (string == NULL) return @[];
    
    NSArray<NSString *> *input = [[NSString stringWithCString:string encoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
    NSMutableArray<NSString *> *list = [NSMutableArray arrayWithCapacity:input.count];
    for (NSString *name in input) {
        // TODO: why list.firstObject
        if (name.length == 0 || [list.firstObject isEqualToString:@""]) {
            continue;
        }
        [list addObject:name];
    }
    return list;
}

static CZLKTask *czlk_taskFromEntry(struct CZLKEntry entry, CZLKLogger *logger) {
    CZLKTask *task = [[CZLKTask alloc] init];
    
    task.ft = [NSString stringWithCString:entry.ft encoding:NSUTF8StringEncoding];
    task.tid = [NSString stringWithCString:entry.tid encoding:NSUTF8StringEncoding];
    task.needMainThread = entry.needMainThread;
    task.dependency = czlk_dependenciesfromString(entry.dependency);
    task.premise = czlk_dependenciesfromString(entry.premise);
    task.priority = entry.priority;
    task.desc = [NSString stringWithCString:entry.desc encoding:NSUTF8StringEncoding];
    
    __weak typeof(task) weakTask = task;
    task.operation = ^{
        void(^standardOperation)(void) = ^{
            [logger recordTask:weakTask execute:^{
                void (*func)(void) = (void (*)(void))entry.func;
                func();
            }];
        };
        if (CZLKManager.shared.customExecute) {
            CZLKManager.shared.customExecute(entry, standardOperation);
        } else {
            standardOperation();
        }
    };
    
    // task队列添加优先级
    if (task.priority == CZLKPriorityVeryHigh) {
        task.queuePriority = NSOperationQueuePriorityVeryHigh;
    } else if (task.priority >= CZLKPriorityHigh) {
        task.queuePriority = NSOperationQueuePriorityHigh;
    } else if (task.priority == CZLKPriorityDefault) {
        task.queuePriority = NSOperationQueuePriorityNormal;
    } else if (task.priority == CZLKPriorityLow) {
        task.queuePriority = NSOperationQueuePriorityLow;
    } else {
        task.queuePriority = NSOperationQueuePriorityVeryLow;
    }
    
    return task;
}

static NSArray<CZLKTask *>* czlk_task_array(CZLKLogger *logger) {
    NSString *appName = [NSString stringWithFormat:@"/%@.app/", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey]];
    __unused char *appNameC = (char *)[appName UTF8String];
    NSMutableArray<CZLKTask *> *result = [NSMutableArray array];
    
    int num = _dyld_image_count();
    for (int i = 0; i < num; i ++) {
        __unused const char *name = _dyld_get_image_name(i);
#ifndef __x86_64__
#ifndef DEBUG
        // 兼容模拟器以及M1上编译运行 - framework不在app目录的情况下，此时去掉检查
        if (strstr(name, appNameC) == NULL) continue;
#endif
#endif
        const struct mach_header *header = _dyld_get_image_header(i);
        
        Dl_info info;
        dladdr(header, &info);
        
        const CZLKExportValue dli_fbase = (CZLKExportValue)info.dli_fbase;
        const CZLKExportSection *section = CZLKGetSectByNameFromHeader((mach_header_t *)header, "__DATA", "__czlaunch");
        if (section == NULL) continue;
        
        int offset = sizeof(struct CZLKEntry);
        for (CZLKExportValue addr = section->offset; addr < section->offset + section->size; addr += offset) {
            struct CZLKEntry entry = *(struct CZLKEntry *)(dli_fbase + addr);
            [result addObject:czlk_taskFromEntry(entry, logger)];
        }
    }
    
    return [result copy];
}

@implementation CZLKGenerator
- (NSArray<CZLKTask *> *)generateTasks {
    double start = CFAbsoluteTimeGetCurrent() * 1e3;
    
    NSArray<CZLKTask *> *tasks = czlk_task_array(self.logger);
    [self resolveDependenciesInArray:tasks];
    double duration = CFAbsoluteTimeGetCurrent() * 1e3 - start;
    NSLog(@"[CZLK] generate take: %lf ms", duration);
    return tasks;
}

/// 根据依赖 taskID 生成 dependencies 并添加依赖关系
/// @param collection task 集合
- (void)resolveDependenciesInArray:(NSArray<CZLKTask *> *)collection {
    // TODO: 可以用更高效的算法去优化
    [collection enumerateObjectsUsingBlock:^(CZLKTask * _Nonnull first, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [collection enumerateObjectsUsingBlock:^(CZLKTask * _Nonnull second, NSUInteger idx, BOOL * _Nonnull stop) {
            // 注册时只有该注册项写入的依赖和逆依赖关系，并不完整，这里补充下
            if ([first.dependency containsObject:second.tid]) {
                if (![second.dependency containsObject:second.tid]) {
                    second.premise = [second.premise arrayByAddingObject:first.tid];
                }
                [first addDependency:second];
            }
            
            if ([first.premise containsObject:second.tid]) {
                if (![second.dependency containsObject:first.tid]) {
                    second.dependency = [second.dependency arrayByAddingObject:first.tid];
                }
                [second addDependency:first];
            }
        }];
        
        BOOL depCountRight = (first.dependency.count == first.dependencies.count);
        // TODO: it doesn't make sense. May never be asserted.
        NSAssert(depCountRight, @"[CZLK] [ERROR] item %@ %@ 依赖项不匹配，可能是启动项ID重复或者依赖的启动项", first.ft, first.tid);
    }];
}
@end
