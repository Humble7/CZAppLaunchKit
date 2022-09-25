//
//  CZLKDefine.h
//  Pods
//
//  Created by ChenZhen on 2022/9/22.
//

#ifndef CZLKDefine_h
#define CZLKDefine_h

/// 注册任务
struct CZLKEntry {
    char * _Nonnull ft;  // 属于哪个模块
    char * _Nonnull tid;  // task唯一ID
    bool needMainThread;  // 是否需要主线程中执行
    char * _Nonnull dependency;  // 依赖列表，使用','分割
    char * _Nonnull premise;  // 被哪些结点依赖，使用','分割
    int priority;  // 优先级
    char * _Nonnull desc;  // 描述信息
    void *_Nullable(* _Nonnull func)(void *_Nullable);  // 启动任务函数体
};


#pragma mark - Task Register For Outside User

#define CZLK_REGISTER(phase, task, after, before, needMainThread, priority, desc) \
static void _CZLK##task(void);                                                    \
__attribute__((used, section("__DATA,__czlaunch")))                               \
static const struct CZLKEntry __FUNC##task = (struct CZLKEntry) {                 \
    (char *)(&#phase),                                                            \
    (char *)(&#task),                                                             \
    needMainThread,                                                               \
    after,                                                                        \
    before,                                                                       \
    priority,                                                                     \
    desc,                                                                         \
    (void *)(&_CZLK##task)                                                        \
};                                                                                \
static void _CZLK##task(void)


#endif /* CZLKDefine_h */
