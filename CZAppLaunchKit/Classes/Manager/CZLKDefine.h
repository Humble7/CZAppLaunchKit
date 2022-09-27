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

#pragma mark - Macro API: Main Setup Phase
#define CZLK_MAIN_SETUP_MAIN_TASK(task, desc) \
CZLK_REGISTER(CZLK_MAIN_SETUP, task, "CZLK_MAIN_SETUP_START", "CZLK_MAIN_SETUP_END", true, 0, desc)

#define CZLK_MAIN_SETUP_BACKGROUND_TASK(task, desc) \
CZLK_REGISTER(CZLK_MAIN_SETUP, task, "CZLK_MAIN_SETUP_START", NULL, false, 0, desc)

#define CZLK_MAIN_SETUP_MAIN_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_MAIN_SETUP, task, after, before, true, 0, desc)

#define CZLK_MAIN_SETUP_BACKGROUND_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_MAIN_SETUP, task, after, before, false, 0, desc)

#pragma mark - Macro API: Monitor Setup Phase

#define CZLK_MONITOR_SETUP_MAIN_TASK(task, desc) \
CZLK_REGISTER(CZLK_MONITOR_SETUP, task, "CZLK_MONITOR_SETUP_START", "CZLK_MONITOR_SETUP_END", true, 0, desc)

#define CZLK_MONITOR_SETUP_BACKGROUND_TASK(task, desc) \
CZLK_REGISTER(CZLK_MONITOR_SETUP, task, "CZLK_MONITOR_SETUP_START", NULL, false, 0, desc)

#define CZLK_MONITOR_SETUP_MAIN_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_MONITOR_SETUP, task, after",CZLK_MONITOR_SETUP_START", before",CZLK_MONITOR_SETUP_END", true, 0, desc)

#define CZLK_MONITOR_SETUP_BACKGROUND_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_MONITOR_SETUP, task, after",CZLK_MONITOR_SETUP_START", before, false, 0, desc)

#pragma mark - Macro API: Server Config Phase
#define CZLK_SERVER_CONFIG_MAIN_TASK(task, desc) \
CZLK_REGISTER(CZLK_SERVER_CONFIG, task, "CZLK_SERVER_CONFIG_START", "CZLK_SERVER_CONFIG_END", true, 0, desc)

#define CZLK_SERVER_CONFIG_BACKGROUND_TASK(task, desc) \
CZLK_REGISTER(CZLK_SERVER_CONFIG, task, "CZLK_SERVER_CONFIG_START", NULL, false, 0, desc)

#define CZLK_SERVER_CONFIG_MAIN_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_SERVER_CONFIG, task, after",CZLK_SERVER_CONFIG_START", before",CZLK_SERVER_CONFIG_END", true, 0, desc)

#define CZLK_SERVER_CONFIG_BACKGROUND_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_SERVER_CONFIG, task, after",CZLK_SERVER_CONFIG_START", before, false, 0, desc)

#pragma mark - Macro API: Data Setup Phase
#define CZLK_DATA_SETUP_MAIN_TASK(task, desc) \
CZLK_REGISTER(CZLK_DATA_SETUP, task, "CZLK_DATA_SETUP_START", "CZLK_DATA_SETUP_END", true, 0, desc)

#define CZLK_DATA_SETUP_BACKGROUND_TASK(task, desc) \
CZLK_REGISTER(CZLK_DATA_SETUP, task, "CZLK_DATA_SETUP_START", NULL, false, 0, desc)

#define CZLK_DATA_SETUP_MAIN_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_DATA_SETUP, task, after",CZLK_DATA_SETUP_START", before",CZLK_DATA_SETUP_END", true, 0, desc)

#define CZLK_DATA_SETUP_BACKGROUND_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_DATA_SETUP, task, after",CZLK_DATA_SETUP_START", before, false, 0, desc)

#pragma mark - Macro API: UI Prepare Phase
#define CZLK_UI_PREPARE_MAIN_TASK(task, desc) \
CZLK_REGISTER(CZLK_UI_PREPARE, task, "CZLK_UI_PREPARE_START", "CZLK_UI_PREPARE_END", true, 0, desc)

#define CZLK_UI_PREPARE_BACKGROUND_TASK(task, desc) \
CZLK_REGISTER(CZLK_UI_PREPARE, task, "CZLK_UI_PREPARE_START", NULL, false, 0, desc)

#define CZLK_UI_PREPARE_MAIN_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_UI_PREPARE, task, after",CZLK_UI_PREPARE_START", before",CZLK_UI_PREPARE_END", true, 0, desc)

#define CZLK_UI_PREPARE_BACKGROUND_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_UI_PREPARE, task, after",CZLK_UI_PREPARE_START", before, false, 0, desc)

#pragma mark - Macro API: UI Setup Phase
#define CZLK_UI_SETUP_MAIN_TASK(task, desc) \
CZLK_REGISTER(CZLK_UI_SETUP, task, "CZLK_UI_SETUP_START", "CZLK_UI_SETUP_END", true, 0, desc)

#define CZLK_UI_SETUP_BACKGROUND_TASK(task, desc) \
CZLK_REGISTER(CZLK_UI_SETUP, task, "CZLK_UI_SETUP_START", NULL, false, 0, desc)

#define CZLK_UI_SETUP_MAIN_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_UI_SETUP, task, after",CZLK_UI_SETUP_START", before",CZLK_UI_SETUP_END", true, 0, desc)

#define CZLK_UI_SETUP_BACKGROUND_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_UI_SETUP, task, after",CZLK_UI_SETUP_START", before, false, 0, desc)

#pragma mark - Macro API: UI Post Phase
#define CZLK_UI_POST_MAIN_TASK(task, desc) \
CZLK_REGISTER(CZLK_UI_POST, task, "CZLK_UI_POST_START", "CZLK_UI_POST_END", true, 0, desc)

#define CZLK_UI_POST_BACKGROUND_TASK(task, desc) \
CZLK_REGISTER(CZLK_UI_POST, task, "CZLK_UI_POST_START", NULL, false, 0, desc)

#define CZLK_UI_POST_MAIN_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_UI_POST, task, after",CZLK_UI_POST_START", before",CZLK_UI_POST_END", true, 0, desc)

#define CZLK_UI_POST_BACKGROUND_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_UI_POST, task, after",CZLK_UI_POST_START", before, false, 0, desc)

#pragma mark - Macro API: Before Render Phase
#define CZLK_BEFORE_RENDER_MAIN_TASK(task, desc) \
CZLK_REGISTER(CZLK_BEFORE_RENDER, task, "CZLK_BEFORE_RENDER_START", "CZLK_BEFORE_RENDER_END", true, 0, desc)

#define CZLK_BEFORE_RENDER_BACKGROUND_TASK(task, desc) \
CZLK_REGISTER(CZLK_BEFORE_RENDER, task, "CZLK_BEFORE_RENDER_START", NULL, false, 0, desc)

#define CZLK_BEFORE_RENDER_MAIN_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_BEFORE_RENDER, task, after",CZLK_BEFORE_RENDER_START", before",CZLK_BEFORE_RENDER_END", true, 0, desc)

#define CZLK_BEFORE_RENDER_BACKGROUND_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_BEFORE_RENDER, task, after",CZLK_BEFORE_RENDER_START", before, false, 0, desc)

#pragma mark - Macro API: Third SDK
#define CZLK_THIRD_SDK_MAIN_TASK(task, desc) \
CZLK_REGISTER(CZLK_THIRD_SDK, task, "CZLK_THIRD_SDK_START", "CZLK_THIRD_SDK_END", true, 0, desc)

#define CZLK_THIRD_SDK_BACKGROUND_TASK(task, desc) \
CZLK_REGISTER(CZLK_THIRD_SDK, task, "CZLK_THIRD_SDK_START", NULL, false, 0, desc)

#define CZLK_THIRD_SDK_MAIN_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_THIRD_SDK, task, after",CZLK_THIRD_SDK_START", before",CZLK_THIRD_SDK_END", true, 0, desc)

#define CZLK_THIRD_SDK_BACKGROUND_TASK_AFTER_BEFORE(task, after, before, desc) \
CZLK_REGISTER(CZLK_THIRD_SDK, task, after",CZLK_THIRD_SDK_START", before, false, 0, desc)

#endif /* CZLKDefine_h */
