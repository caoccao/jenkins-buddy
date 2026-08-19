import Foundation

enum FrenchStrings {
    static let values: [AppStringKey: String] = [
        .appName: "Jenkins Buddy", .jobs: "Tâches", .settings: "Réglages", .jenkins: "Jenkins", .notifications: "Notifications",
        .serverURL: "URL Jenkins", .serverURLHelp: "Incluez le protocole et l’éventuel chemin de contexte Jenkins.", .username: "Nom d’utilisateur",
        .apiToken: "Jeton API", .apiTokenHelp: "Stocké de façon sécurisée dans votre trousseau de session.",
        .permissionsHelp: "Les autorisations Overall/Read et Job/Read sont requises pour les tâches visibles.",
        .refreshInterval: "Intervalle d’actualisation", .seconds: "secondes", .testConnection: "Tester la connexion",
        .connectionSuccessful: "Connexion réussie",
        .connectionChangeWarning: "Modifier l’URL Jenkins ou l’utilisateur ferme les onglets ouverts et réinitialise les références de notification.",
        .save: "Enregistrer", .saved: "Enregistré", .language: "Langue", .notificationPermission: "Autorisation système",
        .requestPermission: "Demander l’autorisation", .sendTestNotification: "Envoyer une notification test",
        .openSystemSettings: "Ouvrir les Réglages Système",
        .monitoringNote: "Les onglets de tâche ouverts sont surveillés. Fermer un onglet arrête ses notifications.",
        .notificationTestBody: "Les notifications sont correctement configurées.", .notificationsEnabled: "Activer les notifications",
        .notifyBuildStarted: "Build démarré", .notifyBuildSucceeded: "Build réussi", .notifyBuildFailed: "Échec du build",
        .notifyBuildRecovered: "Build rétabli", .playSound: "Émettre un son", .refresh: "Actualiser", .loadingJobs: "Chargement des tâches…",
        .noJobs: "Aucune tâche Jenkins trouvée.", .configureJenkins: "Configurez une connexion Jenkins pour parcourir les tâches.",
        .openSettings: "Ouvrir les réglages", .openInJenkins: "Ouvrir dans Jenkins", .detailView: "Vue détaillée",
        .cardView: "Vue en cartes", .searchJobs: "Rechercher des tâches", .status: "État",
        .lastBuild: "Dernier build", .lastCompletedBuild: "Dernier terminé", .lastSuccessfulBuild: "Dernier réussi",
        .lastFailedBuild: "Dernier échec", .buildNumber: "Build", .startedAt: "Démarré", .duration: "Durée", .inQueue: "Dans la file",
        .yes: "Oui", .no: "Non", .closeTab: "Fermer l’onglet", .jobDetails: "Détails de la tâche",
        .noBuilds: "Aucun build disponible.", .loadingJob: "Chargement de la tâche…", .retry: "Réessayer", .online: "En ligne",
        .offline: "Hors ligne", .updatedNow: "Mis à jour à l’instant", .monitoredJobs: "%d tâches surveillées",
        .eventStarted: "démarré", .eventSucceeded: "réussi", .eventFailed: "échoué", .eventRecovered: "rétabli",
        .notificationBuildWithNumber: "Build nº %d — %@", .notificationBuildWithoutNumber: "Build — %@",
        .quit: "Quitter Jenkins Buddy", .about: "À propos de Jenkins Buddy", .general: "Général", .connectionError: "Erreur de connexion",
        .unknownStatus: "Inconnu", .statusSuccess: "Réussi", .statusFailure: "Échec", .statusUnstable: "Instable",
        .statusAborted: "Annulé", .statusNotBuilt: "Non exécuté", .statusDisabled: "Désactivé", .statusBuilding: "En cours"
    ]
}
