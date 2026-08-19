import Foundation

enum GermanStrings {
    static let values: [AppStringKey: String] = [
        .appName: "Jenkins Buddy", .jobs: "Jobs", .settings: "Einstellungen", .jenkins: "Jenkins", .notifications: "Mitteilungen",
        .serverURL: "Jenkins-URL", .serverURLHelp: "Schema und gegebenenfalls den Jenkins-Kontextpfad angeben.", .username: "Benutzername",
        .apiToken: "API-Token", .apiTokenHelp: "Wird sicher im Anmeldeschlüsselbund gespeichert.",
        .permissionsHelp: "Für sichtbare Jobs sind Overall/Read und Job/Read erforderlich.", .refreshInterval: "Aktualisierungsintervall",
        .seconds: "Sekunden", .testConnection: "Verbindung testen", .connectionSuccessful: "Verbindung erfolgreich",
        .connectionChangeWarning: "Beim Ändern der Jenkins-URL oder des Benutzers werden offene Job-Tabs geschlossen und Mitteilungsreferenzen zurückgesetzt.",
        .save: "Sichern", .saved: "Gesichert", .language: "Sprache", .notificationPermission: "Systemberechtigung",
        .requestPermission: "Berechtigung anfordern", .sendTestNotification: "Testmitteilung senden", .openSystemSettings: "Systemeinstellungen öffnen",
        .monitoringNote: "Offene Job-Tabs werden überwacht. Beim Schließen eines Tabs enden dessen Mitteilungen.",
        .notificationTestBody: "Mitteilungen sind korrekt eingerichtet.", .notificationsEnabled: "Mitteilungen aktivieren",
        .notifyBuildStarted: "Build gestartet", .notifyBuildSucceeded: "Build erfolgreich", .notifyBuildFailed: "Build fehlgeschlagen",
        .notifyBuildRecovered: "Build wiederhergestellt", .playSound: "Ton abspielen", .refresh: "Aktualisieren", .loadingJobs: "Jobs werden geladen…",
        .noJobs: "Keine Jenkins-Jobs gefunden.", .configureJenkins: "Eine Jenkins-Verbindung einrichten, um Jobs anzuzeigen.",
        .openSettings: "Einstellungen öffnen", .openInJenkins: "In Jenkins öffnen", .detailView: "Detailansicht",
        .cardView: "Kartenansicht", .searchJobs: "Jobs suchen", .status: "Status",
        .lastBuild: "Letzter Build", .lastCompletedBuild: "Zuletzt abgeschlossen", .lastSuccessfulBuild: "Zuletzt erfolgreich",
        .lastFailedBuild: "Zuletzt fehlgeschlagen", .buildNumber: "Build", .startedAt: "Gestartet", .duration: "Dauer",
        .inQueue: "In Warteschlange", .yes: "Ja", .no: "Nein", .closeTab: "Tab schließen", .jobDetails: "Jobdetails",
        .noBuilds: "Keine Builds verfügbar.", .loadingJob: "Job wird geladen…", .retry: "Erneut versuchen", .online: "Online",
        .offline: "Offline", .updatedNow: "Gerade aktualisiert", .monitoredJobs: "%d überwachte Jobs",
        .eventStarted: "gestartet", .eventSucceeded: "erfolgreich", .eventFailed: "fehlgeschlagen", .eventRecovered: "wiederhergestellt",
        .notificationBuildWithNumber: "Build #%d — %@", .notificationBuildWithoutNumber: "Build — %@",
        .quit: "Jenkins Buddy beenden", .about: "Über Jenkins Buddy", .general: "Allgemein", .connectionError: "Verbindungsfehler",
        .unknownStatus: "Unbekannt", .statusSuccess: "Erfolgreich", .statusFailure: "Fehlgeschlagen", .statusUnstable: "Instabil",
        .statusAborted: "Abgebrochen", .statusNotBuilt: "Nicht erstellt", .statusDisabled: "Deaktiviert", .statusBuilding: "Wird erstellt"
    ]
}
