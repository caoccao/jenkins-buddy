import Foundation

enum JapaneseStrings {
    static let values: [AppStringKey: String] = [
        .appName: "Jenkins Buddy", .jobs: "ジョブ", .settings: "設定", .jenkins: "Jenkins", .notifications: "通知",
        .serverURL: "Jenkins URL", .serverURLHelp: "スキームと Jenkins のコンテキストパスを含めてください。", .username: "ユーザー名",
        .apiToken: "APIトークン", .apiTokenHelp: "ログインキーチェーンに安全に保存されます。",
        .permissionsHelp: "表示するジョブには Overall/Read と Job/Read 権限が必要です。", .refreshInterval: "更新間隔",
        .seconds: "秒", .testConnection: "接続をテスト", .connectionSuccessful: "接続しました",
        .connectionChangeWarning: "Jenkins URLまたはユーザーを変更すると、開いているジョブタブが閉じられ、通知の基準がリセットされます。",
        .save: "保存", .saved: "保存済み", .language: "言語", .notificationPermission: "システム権限",
        .requestPermission: "権限をリクエスト", .sendTestNotification: "テスト通知を送信", .openSystemSettings: "システム設定を開く",
        .monitoringNote: "開いているジョブタブは監視されます。タブを閉じると通知が停止します。",
        .notificationTestBody: "通知は正しく設定されています。", .notificationsEnabled: "通知を有効にする",
        .notifyBuildStarted: "ビルド開始", .notifyBuildSucceeded: "ビルド成功", .notifyBuildFailed: "ビルド失敗",
        .notifyBuildRecovered: "ビルド復旧", .playSound: "サウンドを再生", .refresh: "更新", .loadingJobs: "ジョブを読み込み中…",
        .noJobs: "Jenkinsジョブが見つかりません。", .configureJenkins: "ジョブを表示するにはJenkins接続を設定してください。",
        .openSettings: "設定を開く", .openInJenkins: "Jenkinsで開く", .detailView: "詳細表示", .cardView: "カード表示",
        .searchJobs: "ジョブを検索", .status: "ステータス",
        .lastBuild: "最新ビルド", .lastCompletedBuild: "最新の完了", .lastSuccessfulBuild: "最新の成功", .lastFailedBuild: "最新の失敗",
        .buildNumber: "ビルド", .startedAt: "開始時刻", .duration: "所要時間", .inQueue: "キュー内", .yes: "はい", .no: "いいえ",
        .closeTab: "タブを閉じる", .jobDetails: "ジョブの詳細", .noBuilds: "利用できるビルドはありません。", .loadingJob: "ジョブを読み込み中…",
        .retry: "再試行", .online: "オンライン", .offline: "オフライン", .updatedNow: "たった今更新", .monitoredJobs: "監視中のジョブ：%d件",
        .eventStarted: "開始", .eventSucceeded: "成功", .eventFailed: "失敗", .eventRecovered: "復旧",
        .notificationBuildWithNumber: "ビルド #%d — %@", .notificationBuildWithoutNumber: "ビルド — %@",
        .quit: "Jenkins Buddyを終了", .about: "Jenkins Buddyについて", .general: "一般", .connectionError: "接続エラー",
        .unknownStatus: "不明", .statusSuccess: "成功", .statusFailure: "失敗", .statusUnstable: "不安定",
        .statusAborted: "中止", .statusNotBuilt: "未ビルド", .statusDisabled: "無効", .statusBuilding: "ビルド中"
    ]
}
