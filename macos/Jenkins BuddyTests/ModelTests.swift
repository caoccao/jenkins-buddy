import Foundation
import Testing
@testable import Jenkins_Buddy

@Suite("Models")
struct ModelTests {
    @Test("Languages expose stable codes, native titles, and locale resolution")
    func languageResolution() throws {
        #expect(AppLanguage.preferred(from: []) == .english)
        #expect(AppLanguage.preferred(from: ["en-US"]) == .english)
        #expect(AppLanguage.preferred(from: ["zh-Hans-CN"]) == .simplifiedChinese)
        #expect(AppLanguage.preferred(from: ["zh-Hant-TW"]) == .traditionalChineseTW)
        #expect(AppLanguage.preferred(from: ["zh-HK"]) == .traditionalChineseHK)
        #expect(AppLanguage.preferred(from: ["ja-JP"]) == .japanese)
        #expect(AppLanguage.preferred(from: ["de-DE"]) == .german)
        #expect(AppLanguage.preferred(from: ["fr-FR"]) == .french)
        #expect(AppLanguage.preferred(from: ["es-ES"]) == .spanish)
        #expect(AppLanguage.preferred(from: ["pt-BR"]) == .portuguese)
        #expect(AppLanguage.preferred(from: ["ko-KR"]) == .korean)
        #expect(AppLanguage.english.locale.identifier == "en")
        #expect(AppLanguage.allCases.allSatisfy { !$0.title.isEmpty })
        #expect(AppLanguage.sortedByTitle.count == AppLanguage.allCases.count)

        let codes = Set(AppLanguage.allCases.map(\.rawValue))
        #expect(codes == ["en", "es", "fr", "de", "pt", "zh-Hans", "zh-Hant-HK", "zh-Hant-TW", "ja", "ko"])
        #expect(try JSONDecoder().decode(AppLanguage.self, from: Data(#""traditionalChinese""#.utf8)) == .traditionalChineseTW)
        #expect(try JSONDecoder().decode(AppLanguage.self, from: Data(#""portugueseBrazil""#.utf8)) == .portuguese)
        #expect(AppLanguage.allCases.contains(try JSONDecoder().decode(AppLanguage.self, from: Data(#""system""#.utf8))))
    }

    @Test("Connection validates and normalizes Jenkins URLs")
    func connectionValidation() throws {
        #expect(throws: JenkinsConnectionError.emptyURL) {
            try JenkinsConnection(serverURL: "  ", username: "u", token: "t")
        }
        #expect(throws: JenkinsConnectionError.unsupportedScheme) {
            try JenkinsConnection(serverURL: "ftp://example.com", username: "u", token: "t")
        }
        #expect(throws: JenkinsConnectionError.missingHost) {
            try JenkinsConnection(serverURL: "https:///jenkins", username: "u", token: "t")
        }
        #expect(throws: JenkinsConnectionError.invalidURL) {
            try JenkinsConnection(serverURL: "https://user@example.com/?token=secret", username: "u", token: "t")
        }
        let value = try JenkinsConnection(
            serverURL: " https://example.com/jenkins/// ",
            username: " developer ",
            token: "secret"
        )
        #expect(value.baseURL.absoluteString == "https://example.com/jenkins/")
        #expect(value.username == "developer")
        #expect(value.authorizationHeader == "Basic ZGV2ZWxvcGVyOnNlY3JldA==")
        #expect(JenkinsConnectionError.invalidURL.errorDescription != nil)
        #expect(JenkinsConnectionError.unsupportedScheme.errorDescription != nil)
        #expect(JenkinsConnectionError.insecureHTTP.errorDescription != nil)
        #expect(JenkinsConnectionError.missingHost.errorDescription != nil)
        #expect(throws: JenkinsConnectionError.insecureHTTP) {
            try JenkinsConnection(serverURL: "http://example.com", username: "u", token: "t")
        }
        #expect(try JenkinsConnection(serverURL: "http://localhost:8080", username: "u", token: "t").baseURL.scheme == "http")
    }

    @Test("Jenkins colors and results map to statuses")
    func buildStatusMapping() {
        let colors: [(String?, BuildStatus)] = [
            (nil, .unknown), ("", .unknown), ("blue", .success), ("green", .success),
            ("red", .failure), ("yellow", .unstable), ("aborted", .aborted),
            ("notbuilt", .notBuilt), ("disabled", .disabled), ("purple", .unknown),
            ("grey", .notBuilt), ("blue_anime", .building)
        ]
        for (color, expected) in colors {
            #expect(BuildStatus(jenkinsColor: color) == expected)
        }
        let results: [(String?, Bool, BuildStatus)] = [
            ("SUCCESS", false, .success), ("FAILURE", false, .failure),
            ("UNSTABLE", false, .unstable), ("ABORTED", false, .aborted),
            ("NOT_BUILT", false, .notBuilt), (nil, false, .unknown),
            ("SUCCESS", true, .building)
        ]
        for (result, building, expected) in results {
            #expect(BuildStatus(result: result, building: building) == expected)
        }
        #expect(BuildStatus.failure.isFailure)
        #expect(BuildStatus.unstable.isFailure)
        #expect(!BuildStatus.success.isFailure)
    }

    @Test("Job payloads decode recursively")
    func recursiveJobs() throws {
        let data = Data(#"{"jobs":[{"name":"folder","fullName":"folder","url":"https://example.com/job/folder/","color":null,"jobs":[{"name":"child","fullName":null,"url":"https://example.com/job/folder/job/child/","color":"red","jobs":[]}]}]}"#.utf8)
        let response = try JSONDecoder().decode(JenkinsJobResponse.self, from: data)
        let folder = try #require(response.jobs.first?.model())
        #expect(folder.isContainer)
        #expect(folder.children.first?.fullName == "folder/child")
        #expect(folder.children.first?.status == .failure)
        #expect(folder.children.first?.isContainer == false)
    }

    @Test("Multibranch metadata takes precedence over the buildable flag")
    func multibranchClassification() {
        let project = JenkinsJob(
            name: "edge-composite",
            fullName: "HiveMQ4/edge-composite",
            url: Samples.secondJobURL,
            color: nil,
            objectClass: "org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject",
            buildable: true,
            children: []
        )
        let branch = JenkinsJob(
            name: "bugfix/EDG-835/allow-null-in-comment",
            fullName: "HiveMQ4/edge-composite/bugfix/EDG-835/allow-null-in-comment",
            url: Samples.jobURL,
            color: "blue",
            objectClass: "org.jenkinsci.plugins.workflow.job.WorkflowJob",
            buildable: true,
            children: []
        )
        #expect(project.isContainer)
        #expect(!branch.isContainer)
    }

    @Test("Encoded multibranch names decode only for display")
    func encodedMultibranchDisplayNames() {
        let url = Samples.url(
            "https://jenkins.example.com/job/project/job/bugfix%252FEDG-835%252Fallow-null-in-comment/"
        )
        let job = JenkinsJob(
            name: "bugfix%252FEDG-835%252Fallow-null-in-comment",
            fullName: "project/bugfix%2FEDG-835%2Fallow-null-in-comment",
            url: url,
            color: "blue",
            children: []
        )
        #expect(job.displayName == "bugfix/EDG-835/allow-null-in-comment")
        #expect(job.displayFullName == "project/bugfix/EDG-835/allow-null-in-comment")
        #expect(job.url == url)
        #expect(job.id.contains(job.fullName))
    }

    @Test("Job detail derives a snapshot and build values")
    func jobSnapshot() throws {
        let data = Data(##"{"name":"mobile","fullName":"team/mobile","url":"https://example.com/job/mobile/","color":"blue","description":null,"buildable":null,"inQueue":null,"lastBuild":{"number":7,"url":"https://example.com/job/mobile/7/","result":"SUCCESS","building":false,"timestamp":1700000000000,"duration":65000,"estimatedDuration":70000,"displayName":"#7"},"lastCompletedBuild":null,"lastSuccessfulBuild":null,"lastFailedBuild":null}"##.utf8)
        let response = try JSONDecoder().decode(JenkinsJobDetailResponse.self, from: data)
        let snapshot = response.snapshot(fetchedAt: Date(timeIntervalSince1970: 5))
        #expect(snapshot.name == "team/mobile")
        #expect(snapshot.buildable)
        #expect(!snapshot.inQueue)
        #expect(snapshot.status == .success)
        #expect(snapshot.lastBuild?.startedAt == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(snapshot.buildHistory.map(\.number) == [7])

        let noBuild = JobSnapshot(
            name: "empty", url: Samples.jobURL, color: "disabled", description: nil,
            buildable: false, inQueue: true, lastBuild: nil, lastCompletedBuild: nil,
            lastSuccessfulBuild: nil, lastFailedBuild: nil, fetchedAt: .distantPast
        )
        #expect(noBuild.status == .disabled)
        #expect(noBuild.buildHistory.isEmpty)
        #expect(snapshot.displayName == "team/mobile")
    }

    @Test("Settings decide which events are allowed")
    func notificationSettings() {
        var settings = NotificationSettings()
        #expect(BuildEvent.Kind.allCases.allSatisfy { !settings.allows($0) })
        settings.isEnabled = true
        #expect(!settings.allows(.started))
        #expect(!settings.allows(.succeeded))
        #expect(settings.allows(.failed))
        #expect(settings.allows(.unstable))
        settings.buildStarted = true
        #expect(settings.allows(.started))
        settings.buildSucceeded = true
        #expect(settings.allows(.succeeded))
        settings.isEnabled = false
        #expect(BuildEvent.Kind.allCases.allSatisfy { !settings.allows($0) })
    }

    @Test("Settings decode missing fields to canonical defaults")
    func settingsCompatibility() throws {
        let state = try JSONDecoder().decode(AppSettingsState.self, from: Data(#"{"jenkins":{"serverURL":"https://example.com/"},"notifications":{"buildFailed":false}}"#.utf8))
        #expect(state.language == .english)
        #expect(state.jenkins.username.isEmpty)
        #expect(state.jenkins.refreshInterval == 30)
        #expect(!state.notifications.buildFailed)
        #expect(state.notifications.playSound)
        #expect(JobDetailViewMode.allCases.map(\.rawValue) == ["detail", "card"])
    }

    @Test("Session normalization restores the permanent Jobs tab")
    func sessionNormalization() {
        let duplicateA = AppTab.job(title: "A", url: Samples.jobURL)
        let duplicateB = AppTab.job(title: "B", url: Samples.jobURL)
        let invalid = AppTab(id: UUID(), kind: .job, title: "Invalid", jobURL: nil)
        let state = AppSessionState(tabs: [duplicateA, duplicateB, invalid], selectedTabID: UUID()).normalized()
        #expect(state.tabs.count == 2)
        #expect(state.tabs.first == .jobs)
        #expect(state.selectedTabID == AppTab.jobsID)

        let selected = AppSessionState(tabs: [.jobs, duplicateA], selectedTabID: duplicateA.id).normalized()
        #expect(selected.selectedTabID == duplicateA.id)

        let legacyTabData = Data(
            """
            {"id":"\(duplicateA.id.uuidString)","kind":"job","title":"A","jobURL":"\(Samples.jobURL.absoluteString)"}
            """.utf8
        )
        let legacyTab = try? JSONDecoder().decode(AppTab.self, from: legacyTabData)
        #expect(legacyTab?.jobDetailViewMode == .detail)
    }

    @Test("Tabs deduplicate, select, and close predictably")
    func tabCollection() {
        var tabs = TabCollection()
        let first = Samples.job()
        let second = Samples.job(name: "backend", url: Samples.secondJobURL)
        let firstID = tabs.open(job: first)
        #expect(tabs.open(job: first) == firstID)
        let secondID = tabs.open(job: second)
        #expect(tabs.tabs.count == 3)
        tabs.select(UUID())
        #expect(tabs.selectedTabID == secondID)
        tabs.select(firstID)
        tabs.close(firstID)
        #expect(tabs.selectedTabID == secondID)
        tabs.close(secondID)
        #expect(tabs.selectedTabID == AppTab.jobsID)
        tabs.close(AppTab.jobsID)
        #expect(tabs.tabs == [.jobs])

        var unselectedClose = TabCollection()
        let a = unselectedClose.open(job: first)
        _ = unselectedClose.open(job: second)
        unselectedClose.close(a)
        #expect(unselectedClose.selectedTab.jobURL == Samples.secondJobURL)
    }

    @Test("Job tabs persist individual view modes and reorder behind Jobs")
    func tabPreferencesAndReordering() throws {
        var tabs = TabCollection()
        let firstID = tabs.open(job: Samples.job())
        let secondID = tabs.open(job: Samples.job(name: "backend", url: Samples.secondJobURL))
        let thirdURL = Samples.url("https://jenkins.example.com/jenkins/job/desktop/")
        let thirdID = tabs.open(job: Samples.job(name: "desktop", url: thirdURL))

        tabs.setJobDetailViewMode(.card, for: firstID)
        tabs.setJobDetailViewMode(.card, for: AppTab.jobsID)
        #expect(tabs.tabs.first { $0.id == firstID }?.jobDetailViewMode == .card)
        #expect(tabs.tabs.first?.jobDetailViewMode == .detail)

        tabs.move(firstID, to: thirdID)
        #expect(tabs.tabs.compactMap(\.jobURL) == [Samples.secondJobURL, thirdURL, Samples.jobURL])
        tabs.move(firstID, to: secondID)
        #expect(tabs.tabs.compactMap(\.jobURL) == [Samples.jobURL, Samples.secondJobURL, thirdURL])
        tabs.move(AppTab.jobsID, to: thirdID)
        tabs.move(secondID, to: AppTab.jobsID)
        #expect(tabs.tabs.first == .jobs)

        let data = try JSONEncoder().encode(tabs.state)
        let restored = try JSONDecoder().decode(AppSessionState.self, from: data).normalized()
        #expect(restored.tabs.first { $0.id == firstID }?.jobDetailViewMode == .card)
    }
}
