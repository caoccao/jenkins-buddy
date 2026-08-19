import Foundation

enum TraditionalChineseTWStrings {
    static let values: [AppStringKey: String] = [
        .appName: "Jenkins Buddy", .jobs: "作業", .settings: "設定", .jenkins: "Jenkins", .notifications: "通知",
        .serverURL: "Jenkins 網址", .serverURLHelp: "包含通訊協定及任何 Jenkins 內容路徑。", .username: "使用者名稱",
        .apiToken: "API 權杖", .apiTokenHelp: "安全地儲存在登入鑰匙圈中。",
        .permissionsHelp: "需要可見作業的 Overall/Read 及 Job/Read 權限。", .refreshInterval: "重新整理間隔",
        .seconds: "秒", .testConnection: "測試連線", .connectionSuccessful: "連線成功",
        .connectionChangeWarning: "變更 Jenkins 網址或使用者會關閉已開啟的作業分頁並重設通知基準。",
        .save: "儲存", .saved: "已儲存", .language: "語言", .notificationPermission: "系統權限",
        .requestPermission: "要求權限", .sendTestNotification: "傳送測試通知", .openSystemSettings: "開啟系統設定",
        .monitoringNote: "已開啟的作業分頁會受到監控。關閉作業分頁會停止其通知。",
        .notificationTestBody: "通知已正確設定。", .notificationsEnabled: "啟用通知",
        .notifyBuildStarted: "建置開始", .notifyBuildSucceeded: "建置成功", .notifyBuildFailed: "建置失敗",
        .notifyBuildRecovered: "建置已恢復", .playSound: "播放聲音", .refresh: "重新整理", .loadingJobs: "正在載入作業…",
        .noJobs: "找不到 Jenkins 作業。", .configureJenkins: "設定 Jenkins 連線以瀏覽作業。", .openSettings: "開啟設定",
        .openInJenkins: "在 Jenkins 中開啟", .detailView: "詳細檢視", .cardView: "卡片檢視", .searchJobs: "搜尋作業",
        .status: "狀態", .lastBuild: "最近建置",
        .lastCompletedBuild: "最近完成", .lastSuccessfulBuild: "最近成功", .lastFailedBuild: "最近失敗",
        .buildNumber: "建置", .startedAt: "開始時間", .duration: "持續時間", .inQueue: "佇列中", .yes: "是", .no: "否",
        .closeTab: "關閉分頁", .jobDetails: "作業詳細資料", .noBuilds: "沒有可用的建置。", .loadingJob: "正在載入作業…",
        .retry: "重試", .online: "線上", .offline: "離線", .updatedNow: "剛剛更新", .monitoredJobs: "%d 個受監控的作業",
        .eventStarted: "已開始", .eventSucceeded: "成功", .eventFailed: "失敗", .eventRecovered: "已恢復",
        .notificationBuildWithNumber: "建置 #%d — %@", .notificationBuildWithoutNumber: "建置 — %@",
        .quit: "結束 Jenkins Buddy", .about: "關於 Jenkins Buddy", .general: "一般", .connectionError: "連線錯誤",
        .unknownStatus: "未知", .statusSuccess: "成功", .statusFailure: "失敗", .statusUnstable: "不穩定",
        .statusAborted: "已中止", .statusNotBuilt: "未建置", .statusDisabled: "已停用", .statusBuilding: "建置中"
    ]
}
