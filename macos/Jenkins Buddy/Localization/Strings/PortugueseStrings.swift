import Foundation

enum PortugueseStrings {
    static let values: [AppStringKey: String] = [
        .appName: "Jenkins Buddy", .jobs: "Tarefas", .settings: "Definições", .jenkins: "Jenkins", .notifications: "Notificações",
        .serverURL: "URL do Jenkins", .serverURLHelp: "Inclua o esquema e qualquer caminho de contexto do Jenkins.", .username: "Utilizador",
        .apiToken: "Token da API", .apiTokenHelp: "Guardado de forma segura no porta-chaves de início de sessão.",
        .permissionsHelp: "São necessárias as permissões Overall/Read e Job/Read para as tarefas visíveis.",
        .refreshInterval: "Intervalo de atualização", .seconds: "segundos", .testConnection: "Testar ligação",
        .connectionSuccessful: "Ligação bem-sucedida",
        .connectionChangeWarning: "Alterar o URL ou o utilizador do Jenkins fecha os separadores abertos e repõe as referências de notificação.",
        .save: "Guardar", .saved: "Guardado", .language: "Idioma", .notificationPermission: "Permissão do sistema",
        .requestPermission: "Pedir permissão", .sendTestNotification: "Enviar notificação de teste",
        .openSystemSettings: "Abrir Definições do Sistema",
        .monitoringNote: "Os separadores de tarefas abertos são monitorizados. Fechar um separador interrompe as respetivas notificações.",
        .notificationTestBody: "As notificações estão configuradas corretamente.", .notificationsEnabled: "Ativar notificações",
        .notifyBuildStarted: "Build iniciado", .notifyBuildSucceeded: "Build concluído", .notifyBuildFailed: "Falha no build",
        .notifyBuildRecovered: "Build recuperado", .playSound: "Reproduzir som", .refresh: "Atualizar", .loadingJobs: "A carregar tarefas…",
        .noJobs: "Não foram encontradas tarefas do Jenkins.", .configureJenkins: "Configure uma ligação ao Jenkins para explorar tarefas.",
        .openSettings: "Abrir definições", .openInJenkins: "Abrir no Jenkins", .detailView: "Vista detalhada",
        .cardView: "Vista de cartões", .searchJobs: "Pesquisar tarefas", .status: "Estado",
        .lastBuild: "Último build", .lastCompletedBuild: "Último concluído", .lastSuccessfulBuild: "Último com sucesso",
        .lastFailedBuild: "Último com falha", .buildNumber: "Build", .startedAt: "Iniciado", .duration: "Duração",
        .inQueue: "Na fila", .yes: "Sim", .no: "Não", .closeTab: "Fechar separador", .jobDetails: "Detalhes da tarefa",
        .noBuilds: "Não existem builds disponíveis.", .loadingJob: "A carregar tarefa…", .retry: "Tentar novamente", .online: "Online",
        .offline: "Offline", .updatedNow: "Atualizado agora", .monitoredJobs: "%d tarefas monitorizadas",
        .eventStarted: "iniciado", .eventSucceeded: "concluído", .eventFailed: "falhou", .eventRecovered: "recuperado",
        .notificationBuildWithNumber: "Build n.º %d — %@", .notificationBuildWithoutNumber: "Build — %@",
        .quit: "Sair do Jenkins Buddy", .about: "Acerca do Jenkins Buddy", .general: "Geral", .connectionError: "Erro de ligação",
        .unknownStatus: "Desconhecido", .statusSuccess: "Sucesso", .statusFailure: "Falha", .statusUnstable: "Instável",
        .statusAborted: "Abortado", .statusNotBuilt: "Não executado", .statusDisabled: "Desativado", .statusBuilding: "Em curso"
    ]
}
