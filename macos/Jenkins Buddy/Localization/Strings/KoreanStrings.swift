import Foundation

enum KoreanStrings {
    static let values: [AppStringKey: String] = [
        .appName: "Jenkins Buddy", .jobs: "작업", .settings: "설정", .jenkins: "Jenkins", .notifications: "알림",
        .serverURL: "Jenkins URL", .serverURLHelp: "스킴과 Jenkins 컨텍스트 경로를 포함하세요.", .username: "사용자 이름",
        .apiToken: "API 토큰", .apiTokenHelp: "로그인 키체인에 안전하게 저장됩니다.",
        .permissionsHelp: "표시되는 작업에는 Overall/Read 및 Job/Read 권한이 필요합니다.", .refreshInterval: "새로 고침 간격",
        .seconds: "초", .testConnection: "연결 테스트", .connectionSuccessful: "연결 성공",
        .connectionChangeWarning: "Jenkins URL 또는 사용자를 변경하면 열린 작업 탭이 닫히고 알림 기준이 재설정됩니다.",
        .save: "저장", .saved: "저장됨", .language: "언어", .notificationPermission: "시스템 권한",
        .requestPermission: "권한 요청", .sendTestNotification: "테스트 알림 보내기", .openSystemSettings: "시스템 설정 열기",
        .monitoringNote: "열린 작업 탭은 모니터링됩니다. 탭을 닫으면 해당 알림이 중지됩니다.",
        .notificationTestBody: "알림이 올바르게 설정되었습니다.", .notificationsEnabled: "알림 활성화",
        .notifyBuildStarted: "빌드 시작", .notifyBuildSucceeded: "빌드 성공", .notifyBuildFailed: "빌드 실패",
        .notifyBuildRecovered: "빌드 복구", .playSound: "사운드 재생", .refresh: "새로 고침", .loadingJobs: "작업 불러오는 중…",
        .noJobs: "Jenkins 작업을 찾을 수 없습니다.", .configureJenkins: "작업을 탐색하려면 Jenkins 연결을 설정하세요.",
        .openSettings: "설정 열기", .openInJenkins: "Jenkins에서 열기", .detailView: "상세 보기", .cardView: "카드 보기",
        .searchJobs: "작업 검색", .status: "상태",
        .lastBuild: "최근 빌드", .lastCompletedBuild: "최근 완료", .lastSuccessfulBuild: "최근 성공", .lastFailedBuild: "최근 실패",
        .buildNumber: "빌드", .startedAt: "시작 시간", .duration: "기간", .inQueue: "대기열에 있음", .yes: "예", .no: "아니요",
        .closeTab: "탭 닫기", .jobDetails: "작업 세부 정보", .noBuilds: "사용 가능한 빌드가 없습니다.", .loadingJob: "작업 불러오는 중…",
        .retry: "다시 시도", .online: "온라인", .offline: "오프라인", .updatedNow: "방금 업데이트됨", .monitoredJobs: "모니터링 중인 작업 %d개",
        .eventStarted: "시작됨", .eventSucceeded: "성공", .eventFailed: "실패", .eventRecovered: "복구됨",
        .notificationBuildWithNumber: "빌드 #%d — %@", .notificationBuildWithoutNumber: "빌드 — %@",
        .quit: "Jenkins Buddy 종료", .about: "Jenkins Buddy 정보", .general: "일반", .connectionError: "연결 오류",
        .unknownStatus: "알 수 없음", .statusSuccess: "성공", .statusFailure: "실패", .statusUnstable: "불안정",
        .statusAborted: "중단됨", .statusNotBuilt: "빌드 안 됨", .statusDisabled: "비활성화됨", .statusBuilding: "빌드 중"
    ]
}
