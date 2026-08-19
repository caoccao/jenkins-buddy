import Foundation

enum SimplifiedChineseStrings {
    static let values: [AppStringKey: String] = [
        .appName: "Jenkins Buddy", .jobs: "任务", .settings: "设置", .jenkins: "Jenkins", .notifications: "通知",
        .serverURL: "Jenkins 地址", .serverURLHelp: "包含协议和任何 Jenkins 上下文路径。", .username: "用户名",
        .apiToken: "API 令牌", .apiTokenHelp: "安全地存储在登录钥匙串中。",
        .permissionsHelp: "需要对可见任务拥有 Overall/Read 和 Job/Read 权限。", .refreshInterval: "刷新间隔",
        .seconds: "秒", .testConnection: "测试连接", .connectionSuccessful: "连接成功",
        .connectionChangeWarning: "更改 Jenkins 地址或用户将关闭已打开的任务标签页并重置通知基线。",
        .save: "保存", .saved: "已保存", .language: "语言", .notificationPermission: "系统权限",
        .requestPermission: "请求权限", .sendTestNotification: "发送测试通知", .openSystemSettings: "打开系统设置",
        .monitoringNote: "已打开的任务标签页会受到监控。关闭标签页将停止其通知。",
        .notificationTestBody: "通知已正确配置。", .notificationsEnabled: "启用通知",
        .notifyBuildStarted: "构建开始", .notifyBuildSucceeded: "构建成功", .notifyBuildFailed: "构建失败",
        .notifyBuildRecovered: "构建恢复", .playSound: "播放声音", .refresh: "刷新", .loadingJobs: "正在加载任务…",
        .noJobs: "未找到 Jenkins 任务。", .configureJenkins: "配置 Jenkins 连接以浏览任务。", .openSettings: "打开设置",
        .openInJenkins: "在 Jenkins 中打开", .detailView: "详细视图", .cardView: "卡片视图", .searchJobs: "搜索任务",
        .status: "状态", .lastBuild: "最近构建",
        .lastCompletedBuild: "最近完成", .lastSuccessfulBuild: "最近成功", .lastFailedBuild: "最近失败",
        .buildNumber: "构建", .startedAt: "开始时间", .duration: "时长", .inQueue: "队列中", .yes: "是", .no: "否",
        .closeTab: "关闭标签页", .jobDetails: "任务详情", .noBuilds: "没有可用的构建。", .loadingJob: "正在加载任务…",
        .retry: "重试", .online: "在线", .offline: "离线", .updatedNow: "刚刚更新", .monitoredJobs: "%d 个受监控的任务",
        .eventStarted: "已开始", .eventSucceeded: "已成功", .eventFailed: "已失败", .eventRecovered: "已恢复",
        .notificationBuildWithNumber: "构建 #%d — %@", .notificationBuildWithoutNumber: "构建 — %@",
        .quit: "退出 Jenkins Buddy", .about: "关于 Jenkins Buddy", .general: "通用", .connectionError: "连接错误",
        .unknownStatus: "未知", .statusSuccess: "成功", .statusFailure: "失败", .statusUnstable: "不稳定",
        .statusAborted: "已中止", .statusNotBuilt: "未构建", .statusDisabled: "已禁用", .statusBuilding: "构建中"
    ]
}
