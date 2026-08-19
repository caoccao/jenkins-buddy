import Foundation

enum EnglishStrings {
    static let values: [AppStringKey: String] = [
        .appName: "Jenkins Buddy", .jobs: "Jobs", .settings: "Settings", .jenkins: "Jenkins",
        .notifications: "Notifications", .serverURL: "Jenkins URL", .serverURLHelp: "Include the scheme and any Jenkins context path.",
        .username: "User", .apiToken: "API token", .apiTokenHelp: "Stored securely in your login Keychain.",
        .permissionsHelp: "Requires Overall/Read and Job/Read for visible jobs.",
        .refreshInterval: "Refresh interval", .seconds: "seconds", .testConnection: "Test Connection",
        .connectionSuccessful: "Connection successful", .connectionChangeWarning: "Changing the Jenkins URL or user closes open job tabs and resets notification baselines.",
        .save: "Save", .saved: "Saved", .language: "Language",
        .notificationPermission: "System permission", .requestPermission: "Request Permission",
        .sendTestNotification: "Send Test Notification", .openSystemSettings: "Open System Settings",
        .monitoringNote: "Open job tabs are monitored. Closing a job tab stops its notifications.",
        .notificationTestBody: "Notifications are configured correctly.",
        .notificationsEnabled: "Enable notifications", .notifyBuildStarted: "Build started",
        .notifyBuildSucceeded: "Build succeeded", .notifyBuildFailed: "Build failed", .notifyBuildRecovered: "Build recovered",
        .playSound: "Play sound",
        .refresh: "Refresh", .loadingJobs: "Loading jobs…", .noJobs: "No Jenkins jobs were found.",
        .configureJenkins: "Configure a Jenkins connection to browse jobs.", .openSettings: "Open Settings",
        .openInJenkins: "Open in Jenkins", .detailView: "Detail view", .cardView: "Card view",
        .searchJobs: "Search jobs", .status: "Status", .lastBuild: "Last build", .lastCompletedBuild: "Last completed",
        .lastSuccessfulBuild: "Last successful", .lastFailedBuild: "Last failed", .buildNumber: "Build",
        .startedAt: "Started", .duration: "Duration", .inQueue: "In queue", .yes: "Yes", .no: "No",
        .closeTab: "Close tab", .jobDetails: "Job details", .noBuilds: "No builds are available.",
        .loadingJob: "Loading job…", .retry: "Retry", .online: "Online", .offline: "Offline", .updatedNow: "Updated just now",
        .monitoredJobs: "%d monitored jobs",
        .eventStarted: "started", .eventSucceeded: "succeeded", .eventFailed: "failed", .eventRecovered: "recovered",
        .notificationBuildWithNumber: "Build #%d — %@", .notificationBuildWithoutNumber: "Build — %@",
        .quit: "Quit Jenkins Buddy", .about: "About Jenkins Buddy",
        .general: "General", .connectionError: "Connection error", .unknownStatus: "Unknown",
        .statusSuccess: "Succeeded", .statusFailure: "Failed", .statusUnstable: "Unstable", .statusAborted: "Aborted",
        .statusNotBuilt: "Not Built", .statusDisabled: "Disabled", .statusBuilding: "Running"
    ]
}
