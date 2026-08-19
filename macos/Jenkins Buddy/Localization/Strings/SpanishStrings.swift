import Foundation

enum SpanishStrings {
    static let values: [AppStringKey: String] = [
        .appName: "Jenkins Buddy", .jobs: "Tareas", .settings: "Ajustes", .jenkins: "Jenkins", .notifications: "Notificaciones",
        .serverURL: "URL de Jenkins", .serverURLHelp: "Incluye el esquema y cualquier ruta de contexto de Jenkins.", .username: "Usuario",
        .apiToken: "Token de API", .apiTokenHelp: "Se guarda de forma segura en tu llavero de inicio de sesión.",
        .permissionsHelp: "Se necesitan Overall/Read y Job/Read para las tareas visibles.", .refreshInterval: "Intervalo de actualización",
        .seconds: "segundos", .testConnection: "Probar conexión", .connectionSuccessful: "Conexión correcta",
        .connectionChangeWarning: "Cambiar la URL o el usuario de Jenkins cierra las pestañas abiertas y restablece las referencias de notificación.",
        .save: "Guardar", .saved: "Guardado", .language: "Idioma", .notificationPermission: "Permiso del sistema",
        .requestPermission: "Solicitar permiso", .sendTestNotification: "Enviar notificación de prueba",
        .openSystemSettings: "Abrir Ajustes del Sistema",
        .monitoringNote: "Las pestañas de tareas abiertas se supervisan. Al cerrar una pestaña se detienen sus notificaciones.",
        .notificationTestBody: "Las notificaciones están configuradas correctamente.", .notificationsEnabled: "Activar notificaciones",
        .notifyBuildStarted: "Compilación iniciada", .notifyBuildSucceeded: "Compilación correcta", .notifyBuildFailed: "Compilación fallida",
        .notifyBuildRecovered: "Compilación recuperada", .playSound: "Reproducir sonido", .refresh: "Actualizar",
        .loadingJobs: "Cargando tareas…", .noJobs: "No se encontraron tareas de Jenkins.",
        .configureJenkins: "Configura una conexión de Jenkins para explorar tareas.", .openSettings: "Abrir ajustes",
        .openInJenkins: "Abrir en Jenkins", .detailView: "Vista detallada", .cardView: "Vista de tarjetas",
        .searchJobs: "Buscar tareas", .status: "Estado", .lastBuild: "Última compilación",
        .lastCompletedBuild: "Última completada", .lastSuccessfulBuild: "Última correcta", .lastFailedBuild: "Última fallida",
        .buildNumber: "Compilación", .startedAt: "Inicio", .duration: "Duración", .inQueue: "En cola", .yes: "Sí", .no: "No",
        .closeTab: "Cerrar pestaña", .jobDetails: "Detalles de la tarea", .noBuilds: "No hay compilaciones disponibles.",
        .loadingJob: "Cargando tarea…", .retry: "Reintentar", .online: "En línea", .offline: "Sin conexión",
        .updatedNow: "Actualizado ahora", .monitoredJobs: "%d tareas supervisadas", .eventStarted: "iniciada",
        .eventSucceeded: "correcta", .eventFailed: "fallida", .eventRecovered: "recuperada",
        .notificationBuildWithNumber: "Compilación n.º %d — %@", .notificationBuildWithoutNumber: "Compilación — %@",
        .quit: "Salir de Jenkins Buddy", .about: "Acerca de Jenkins Buddy", .general: "General", .connectionError: "Error de conexión",
        .unknownStatus: "Desconocido", .statusSuccess: "Correcto", .statusFailure: "Fallo", .statusUnstable: "Inestable",
        .statusAborted: "Cancelado", .statusNotBuilt: "No compilado", .statusDisabled: "Desactivado", .statusBuilding: "Compilando"
    ]
}
