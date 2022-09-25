//
//  CZLKMacros.h
//  Pods
//
//  Created by ChenZhen on 2022/9/22.
//

#ifndef CZLKMacros_h
#define CZLKMacros_h

#include <CZAppLaunchKit/CZLKDefine.h>
/**
 * CZLK_RECORD_POINT_TASK: 用来锚定系统相关回调
 * CZLK_PHASE_POINT_TASK: 细化系统之间的回调，划分为自定义的阶段
 
 * App Launch 阶段划分：
 * Main : CZLK_PREDEFINED_TASK_MAIN_FUNC_START
 * ----Main Setup          : CZLK_PREDEFINED_TASK_MAIN_SETUP_START
 * WillFinishLaunch      : CZLK_PREDEFINED_TASK_WILL_FINISH_LAUNCH_START
 * ----Monitor Setup      : CZLK_PREDEFINED_TASK_MONITOR_SETUP_START
 * ----Server Config      : CZLK_PREDEFINED_TASK_SERVER_CONFIG_START
 * DidFinishLaunch      : CZLK_PREDEFINED_TASK_DID_FINISH_LAUNCH_START
 * ----Data Setup          : CZLK_PREDEFINED_TASK_DATA_SETUP_START
 * ----UI Prepare           : CZLK_PREDEFINED_TASK_UI_PREPARE_START
 * ----UI Setup              : CZLK_PREDEFINED_TASK_UI_SETUP_START
 * ----UI Post                : CZLK_PREDEFINED_TASK_UI_POST_START
 * ----Before Render     : CZLK_PREDEFINED_TASK_BEFORE_RENDER_START

 */


#pragma mark - Predefined Point Macro
#define CZLK_RECORD_POINT_TASK(task, after, before, desc) \
CZLK_REGISTER(CZLK_RECORD_POINT, task, after, before, true, INT_MAX, desc)

#define CZLK_PHASE_POINT_TASK(task, after, before, desc) \
CZLK_REGISTER(CZLK_PHASE_POINT, task, after, before, true, 1024, desc)

#pragma mark - Timeline(System): main()
#define CZLK_PREDEFINED_TASK_MAIN_FUNC_START() \
CZLK_RECORD_POINT_TASK(CZLK_MAIN_FUNC_START, NULL, "CZLK_MAIN_FUNC_END", "CZAppLaunchKit [main()] start")

#define CZLK_PREDEFINED_TASK_MAIN_FUNC_END() \
CZLK_RECORD_POINT_TASK(CZLK_MAIN_FUNC_END, "CZLK_MAIN_FUNC_START", NULL, "CZAppLaunchKit [main()] end")

#pragma mark - Timeline(CZAppLaunchKit): Main Setup Phase
#define CZLK_PREDEFINED_TASK_MAIN_SETUP_START() \
CZLK_PHASE_POINT_TASK(CZLK_MAIN_SETUP_START, "CZLK_MAIN_FUNC_START", "CZLK_MAIN_FUNC_END", "CZAppLaunchKit phase [mian setup] start")

#define CZLK_PREDEFINED_TASK_MAIN_SETUP_END() \
CZLK_PHASE_POINT_TASK(CZLK_MAIN_SETUP_END, "CZLK_MAIN_SETUP_START", "CZLK_MAIN_FUNC_END", "CZAppLaunchKit phase [mian setup] end")

#pragma mark - Timeline(System): application:willFinishLaunchingWithOptions:
#define CZLK_PREDEFINED_TASK_WILL_FINISH_LAUNCH_START() \
CZLK_RECORD_POINT_TASK(CZLK_WILL_FINISH_LAUNCH_START, NULL, "CZLK_WILL_FINISH_LAUNCH_END", "CZAppLaunchKit phase [application:willFinishLaunchingWithOptions:] start")

#define CZLK_PREDEFINED_TASK_WILL_FINISH_LAUNCH_END() \
CZLK_RECORD_POINT_TASK(CZLK_WILL_FINISH_LAUNCH_END, "CZLK_WILL_FINISH_LAUNCH_START", NULL, "CZAppLaunchKit phase [application:willFinishLaunchingWithOptions:] end")

#pragma mark - Timeline(CZAppLaunchKit): Monitor Setup Phase
// CZLK_MONITOR_SETUP：可以在这个设置App监控相关的SDK初始化
#define CZLK_PREDEFINED_TASK_MONITOR_SETUP_START() \
CZLK_PHASE_POINT_TASK(CZLK_MONITOR_SETUP_START, "CZLK_WILL_FINISH_LAUNCH_START", "CZLK_MONITOR_SETUP_END", "CZAppLaunchKit phase [Monitor Setup] start")

#define CZLK_PREDEFINED_TASK_MONITOR_SETUP_END() \
CZLK_PHASE_POINT_TASK(CZLK_MONITOR_SETUP_END, "CZLK_MONITOR_SETUP_START", "CZLK_SERVER_CONFIG_START", "CZAppLaunchKit phase [Monitor Setup] end")

#pragma mark - Timeline(CZAppLaunchKit): Server Config Phase
// 这个阶段可以获取服务端的配置（尽量避免）
#define CZLK_PREDEFINED_TASK_SERVER_CONFIG_START() \
CZLK_PHASE_POINT_TASK(CZLK_SERVER_CONFIG_START, "CZLK_MONITOR_SETUP_END", "CZLK_SERVER_CONFIG_END", "CZAppLaunchKit phase [Server Config] start")

#define CZLK_PREDEFINED_TASK_SERVER_CONFIG_END() \
CZLK_PHASE_POINT_TASK(CZLK_SERVER_CONFIG_END, "CZLK_SERVER_CONFIG_START", "CZLK_WILL_FINISH_LAUNCH_END", "CZAppLaunchKit phase [Server Config] end")

#pragma mark - Timeline(System): application:didFinishLaunchingWithOptions:
#define CZLK_PREDEFINED_TASK_DID_FINISH_LAUNCH_START() \
CZLK_PHASE_POINT_TASK(CZLK_DID_FINISH_LAUNCH_START, NULL, "CZLK_DID_FINISH_LAUNCH_END", "CZAppLaunchKit phase [application:didFinishLaunchingWithOptions:] start")

#define CZLK_PREDEFINED_TASK_DID_FINISH_LAUNCH_END() \
CZLK_PHASE_POINT_TASK(CZLK_DID_FINISH_LAUNCH_END, "CZLK_DID_FINISH_LAUNCH_START", NULL, "CZAppLaunchKit phase [application:didFinishLaunchingWithOptions:] end")

#pragma mark - Timeline(CZAppLaunchKit): Data Setup Phase
#define CZLK_PREDEFINED_TASK_DATA_SETUP_START() \
CZLK_PHASE_POINT_TASK(CZLK_DATA_SETUP_START, "CZLK_DID_FINISH_LAUNCH_START", "CZLK_DATA_SETUP_END", "CZAppLaunchKit phase [Data Setup] start")

#define CZLK_PREDEFINED_TASK_DATA_SETUP_END() \
CZLK_PHASE_POINT_TASK(CZLK_DATA_SETUP_END, "CZLK_DATA_SETUP_START", "CZLK_UI_PREPARE_START", "CZAppLaunchKit phase [Data Setup] end")

#pragma mark - Timeline(CZAppLaunchKit): UI Prepare Phase
#define CZLK_PREDEFINED_TASK_UI_PREPARE_START() \
CZLK_PHASE_POINT_TASK(CZLK_UI_PREPARE_START, "CZLK_DATA_SETUP_END", "CZLK_UI_PREPARE_END", "CZAppLaunchKit phase [UI Prepare] start")

#define CZLK_PREDEFINED_TASK_UI_PREPARE_END() \
CZLK_PHASE_POINT_TASK(CZLK_UI_PREPARE_END, "CZLK_UI_PREPARE_START", "CZLK_UI_SETUP_START", "CZAppLaunchKit phase [UI Prepare] end")

#pragma mark - Timeline(CZAppLaunchKit): UI Setup Phase
#define CZLK_PREDEFINED_TASK_UI_SETUP_START() \
CZLK_PHASE_POINT_TASK(CZLK_UI_SETUP_START, "CZLK_UI_PREPARE_END", "CZLK_UI_SETUP_END", "CZAppLaunchKit phase [UI Setup] start")

#define CZLK_PREDEFINED_TASK_UI_SETUP_END() \
CZLK_PHASE_POINT_TASK(CZLK_UI_SETUP_END, "CZLK_UI_SETUP_START", "CZLK_UI_POST_START", "CZAppLaunchKit phase [UI Setup] end")

#pragma mark - Timeline(CZAppLaunchKit): UI Post Phase
#define CZLK_PREDEFINED_TASK_UI_POST_START() \
CZLK_PHASE_POINT_TASK(CZLK_UI_POST_START, "CZLK_UI_SETUP_END", "CZLK_UI_POST_END", "CZAppLaunchKit phase [UI Post] start")

#define CZLK_PREDEFINED_TASK_UI_POST_END() \
CZLK_PHASE_POINT_TASK(CZLK_UI_POST_END, "CZLK_UI_POST_START", "CZLK_BEFORE_RENDER_START", "CZAppLaunchKit phase [UI Post] end")

#pragma mark - Timeline(CZAppLaunchKit): Before Render Phase
#define CZLK_PREDEFINED_TASK_BEFORE_RENDER_START() \
CZLK_PHASE_POINT_TASK(CZLK_BEFORE_RENDER_START, "CZLK_UI_POST_END", "CZLK_BEFORE_RENDER_END", "CZAppLaunchKit phase [Before Render] start")

#define CZLK_PREDEFINED_TASK_BEFORE_RENDER_END() \
CZLK_PHASE_POINT_TASK(CZLK_BEFORE_RENDER_END, "CZLK_BEFORE_RENDER_START", "CZLK_DID_FINISH_LAUNCH_END", "CZAppLaunchKit phase [Before Render] end")

#pragma mark - Anchor

#define CZLK_ANCHOR_TASK_VIEW_DID_APPEAR_RECORD @"CZLK_VIEW_DID_APPEAR_RECORD"

#pragma mark - Invoke
#define CZLK_LIFE_CYCLE_ANCHORS() \
CZLK_PREDEFINED_TASK_MAIN_FUNC_START(){} \
CZLK_PREDEFINED_TASK_MAIN_FUNC_END(){}   \
CZLK_PREDEFINED_TASK_MAIN_SETUP_START(){} \
CZLK_PREDEFINED_TASK_MAIN_SETUP_END(){} \
CZLK_PREDEFINED_TASK_WILL_FINISH_LAUNCH_START(){} \
CZLK_PREDEFINED_TASK_WILL_FINISH_LAUNCH_END(){} \
CZLK_PREDEFINED_TASK_MONITOR_SETUP_START(){} \
CZLK_PREDEFINED_TASK_MONITOR_SETUP_END(){}  \
CZLK_PREDEFINED_TASK_SERVER_CONFIG_START(){} \
CZLK_PREDEFINED_TASK_SERVER_CONFIG_END(){} \
CZLK_PREDEFINED_TASK_DID_FINISH_LAUNCH_START(){} \
CZLK_PREDEFINED_TASK_DID_FINISH_LAUNCH_END(){}  \
CZLK_PREDEFINED_TASK_DATA_SETUP_START(){} \
CZLK_PREDEFINED_TASK_DATA_SETUP_END(){} \
CZLK_PREDEFINED_TASK_UI_PREPARE_START(){} \
CZLK_PREDEFINED_TASK_UI_PREPARE_END(){} \
CZLK_PREDEFINED_TASK_UI_SETUP_START(){} \
CZLK_PREDEFINED_TASK_UI_SETUP_END(){} \
CZLK_PREDEFINED_TASK_UI_POST_START(){} \
CZLK_PREDEFINED_TASK_UI_POST_END(){} \
CZLK_PREDEFINED_TASK_BEFORE_RENDER_START(){} \
CZLK_PREDEFINED_TASK_BEFORE_RENDER_END(){}
//CZLK_PREDEFINED_TASK_VIEW_DID_LOAD_RECORD(){} \
//CZLK_PREDEFINED_TASK_VIEW_DID_APPEAR_RECORD(){} \
//CZLK_PREDEFINED_TASK_VIEW_DID_ENTER_BACKGROUND_RECORD(){} \
//CZLK_PREDEFINED_TASK_VIEW_WILL_ENTER_FOREGROUND_RECORD(){} \
//CZLK_PREDEFINED_TASK_PAGE_DID_LOAD_RECORD(){} \
//CZLK_PREDEFINED_TASK_HOME_PAGE_DID_RENDER_START(){} \
//CZLK_PREDEFINED_TASK_HOME_PAGE_DID_RENDER_END(){} \
//CZLK_PREDEFINED_TASK_THIRD_SDK_START(){} \
//CZLK_PREDEFINED_TASK_THIRD_SDK_END(){} \
//CZLK_PREDEFINED_TASK_DATA_COLLECT_START(){} \
//CZLK_PREDEFINED_TASK_DATA_COLLECT_END(){} \
//CZLK_PREDEFINED_TASK_AFTER_RENDER_START(){} \
//CZLK_PREDEFINED_TASK_AFTER_RENDER_END(){} \



#define CZLK_INVOKE_MAIN_FUNC_START_TO_END() \
[CZLKManager executeTasksFrom:@"CZLK_MAIN_FUNC_START" to:@"CZLK_MAIN_FUNC_END"]

#define CZLK_INVOKE_WILL_FINISH_LAUNCH_START_TO_END() \
[CZLKManager executeTasksFrom:@"CZLK_WILL_FINISH_LAUNCH_START" to:@"CZLK_WILL_FINISH_LAUNCH_END"]


#define CZLK_INVOKE_DID_FINISH_LAUNCH_START_TO_END() \
[CZLKManager executeTasksFrom:@"CZLK_DID_FINISH_LAUNCH_START" to:@"CZLK_DID_FINISH_LAUNCH_END"]

#define CZLK_INVOKE_VIEW_DID_APPEAR_RECORD() \
[CZLKManager executeTask:@"CZLK_VIEW_DID_APPEAR_RECORD"]

#endif /* CZLKMacros_h */
