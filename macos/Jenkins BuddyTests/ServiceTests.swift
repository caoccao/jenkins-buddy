import AppKit
import Foundation
import SQLite3
import Testing
@testable import Jenkins_Buddy

@Suite("Services", .serialized)
struct ServiceTests {
    @Test("Endpoints preserve context paths and encode tree queries")
    func endpoints() throws {
        let connection = try Samples.connection()
        let jobsURL = JenkinsEndpoint.jobs.url(relativeTo: connection.baseURL)
        #expect(jobsURL.path == "/jenkins/api/json")
        #expect(URLComponents(url: jobsURL, resolvingAgainstBaseURL: false)?.queryItems?.first?.name == "tree")
        #expect(jobsURL.absoluteString.contains("jobs%5Bname"))

        let jobURL = JenkinsEndpoint.job(Samples.jobURL).url(relativeTo: connection.baseURL)
        #expect(jobURL.path == "/jenkins/job/mobile/api/json")
        #expect(jobURL.absoluteString.contains("lastBuild"))
        let jobTree = URLComponents(url: jobURL, resolvingAgainstBaseURL: false)?.queryItems?.first?.value
        #expect(jobTree?.contains("builds[") == true)
        #expect(jobTree?.contains("{0,50}") == true)
        let childrenURL = JenkinsEndpoint.children(Samples.secondJobURL).url(relativeTo: connection.baseURL)
        #expect(childrenURL.path == "/jenkins/job/backend/api/json")
        #expect(!childrenURL.absoluteString.contains("jobs%5Bname%2CfullName%2Curl%2Ccolor%2C_class%2Cbuildable%2Cjobs"))

        let branchURL = Samples.url(
            "https://jenkins.example.com/jenkins/job/project/job/bugfix%252FEDG-835%252Fallow-null-in-comment/"
        )
        let branchEndpoint = JenkinsEndpoint.job(branchURL).url(relativeTo: connection.baseURL)
        #expect(branchEndpoint.absoluteString.contains("bugfix%252FEDG-835%252Fallow-null-in-comment/api/json"))
    }

    @Test("Redirects are restricted to the same origin")
    func redirects() {
        let original = Samples.url("https://example.com/jenkins/api/json")
        #expect(RedirectPolicy.allows(from: original, to: URL(string: "https://example.com/login")))
        #expect(RedirectPolicy.allows(from: URL(string: "https://example.com:443/a"), to: original))
        #expect(!RedirectPolicy.allows(from: original, to: URL(string: "http://example.com/a")))
        #expect(!RedirectPolicy.allows(from: original, to: URL(string: "https://other.example.com/a")))
        #expect(!RedirectPolicy.allows(from: original, to: URL(string: "https://example.com:444/a")))
        #expect(RedirectPolicy.allows(from: URL(string: "http://example.com/a"), to: original))
        #expect(!RedirectPolicy.allows(from: URL(string: "http://example.com:8080/a"), to: original))
        #expect(!RedirectPolicy.allows(from: nil, to: original))
        #expect(!RedirectPolicy.allows(from: original, to: nil))
        #expect(!RedirectPolicy.allows(from: URL(string: "file:///a"), to: URL(string: "file:///b")))
        #expect(RedirectPolicy.allowsAuthenticatedResource(configuredURL: original, resourceURL: Samples.url("https://example.com/job/a")))
        #expect(!RedirectPolicy.allowsAuthenticatedResource(configuredURL: original, resourceURL: Samples.url("https://other.example.com/job/a")))
        #expect(JenkinsResourceIdentity.matches(Samples.jobURL, Samples.url("https://jenkins.example.com/jenkins/job/mobile")))
        #expect(!JenkinsResourceIdentity.matches(Samples.jobURL, Samples.secondJobURL))
        #expect(!JenkinsResourceIdentity.matches(Samples.jobURL, Samples.url("https://other.example.com/jenkins/job/mobile/")))
    }

    @Test("Jenkins client sends preemptive Basic auth and decodes jobs")
    func clientJobs() async throws {
        let data = Data(#"{"jobs":[{"name":"mobile","fullName":"mobile","url":"https://jenkins.example.com/jenkins/job/mobile/","color":"blue","jobs":[] }]}"#.utf8)
        let transport = MockHTTPTransport([.success(HTTPResponse(data: data, statusCode: 200, url: Samples.baseURL))])
        let client = JenkinsClient(transport: transport)
        let jobs = try await client.fetchJobs(connection: Samples.connection())
        #expect(jobs.count == 1)
        #expect(jobs.first?.status == .success)
        let request = try #require(await transport.recordedRequests().first)
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Basic ZGV2ZWxvcGVyOnNlY3JldA==")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.httpMethod == "GET")
        #expect(request.timeoutInterval == 15)
        #expect(request.value(forHTTPHeaderField: "User-Agent") == "Jenkins-Buddy/1.0 (macOS)")
    }

    @Test("Jenkins client decodes job details")
    func clientJobDetail() async throws {
        let data = Data(#"{"name":"mobile","fullName":null,"url":"https://jenkins.example.com/jenkins/job/mobile/","color":"red","description":"desc","buildable":true,"inQueue":false,"lastBuild":null,"lastCompletedBuild":null,"lastSuccessfulBuild":null,"lastFailedBuild":null}"#.utf8)
        let transport = MockHTTPTransport([.success(HTTPResponse(data: data, statusCode: 200, url: Samples.jobURL))])
        let snapshot = try await JenkinsClient(transport: transport).fetchJob(
            url: Samples.jobURL,
            connection: Samples.connection()
        )
        #expect(snapshot.name == "mobile")
        #expect(snapshot.status == .failure)
        #expect(snapshot.description == "desc")
    }

    @Test("Jenkins client rejects details for a different job")
    func clientRejectsMismatchedJobDetail() async throws {
        let data = Data(#"{"name":"backend","fullName":"backend","url":"https://jenkins.example.com/jenkins/job/backend/","color":"blue","description":null,"buildable":true,"inQueue":false,"lastBuild":null,"lastCompletedBuild":null,"lastSuccessfulBuild":null,"lastFailedBuild":null}"#.utf8)
        let transport = MockHTTPTransport([
            .success(HTTPResponse(data: data, statusCode: 200, url: Samples.jobURL))
        ])
        await #expect(throws: JenkinsClientError.invalidPayload) {
            try await JenkinsClient(transport: transport).fetchJob(
                url: Samples.jobURL,
                connection: Samples.connection()
            )
        }
    }

    @Test("Jenkins client keeps distinct build references")
    func clientKeepsDistinctBuildReferences() async throws {
        let data = Data(#"""
        {
          "name": "mobile",
          "fullName": "team/mobile",
          "url": "https://jenkins.example.com/jenkins/job/mobile/",
          "color": "yellow",
          "description": null,
          "buildable": true,
          "inQueue": false,
          "builds": [
            {
              "number": 15, "url": "https://jenkins.example.com/jenkins/job/mobile/15/",
              "result": "FAILURE", "building": false, "timestamp": 1699998000000,
              "duration": 3000, "estimatedDuration": 3000, "displayName": "#15"
            },
            {
              "number": 17, "url": "https://jenkins.example.com/jenkins/job/mobile/17/",
              "result": "UNSTABLE", "building": false, "timestamp": 1700000000000,
              "duration": 1000, "estimatedDuration": 1000, "displayName": "#17"
            },
            {
              "number": 16, "url": "https://jenkins.example.com/jenkins/job/mobile/16/",
              "result": "SUCCESS", "building": false, "timestamp": 1699999000000,
              "duration": 2000, "estimatedDuration": 2000, "displayName": "#16"
            },
            {
              "number": 16, "url": "https://jenkins.example.com/jenkins/job/mobile/16/",
              "result": "SUCCESS", "building": false, "timestamp": 1699999000000,
              "duration": 2000, "estimatedDuration": 2000, "displayName": "#16"
            }
          ],
          "lastBuild": {
            "number": 17, "url": "https://jenkins.example.com/jenkins/job/mobile/17/",
            "result": "UNSTABLE", "building": false, "timestamp": 1700000000000,
            "duration": 1000, "estimatedDuration": 1000, "displayName": "#17"
          },
          "lastCompletedBuild": {
            "number": 16, "url": "https://jenkins.example.com/jenkins/job/mobile/16/",
            "result": "SUCCESS", "building": false, "timestamp": 1699999000000,
            "duration": 2000, "estimatedDuration": 2000, "displayName": "#16"
          },
          "lastSuccessfulBuild": {
            "number": 16, "url": "https://jenkins.example.com/jenkins/job/mobile/16/",
            "result": "SUCCESS", "building": false, "timestamp": 1699999000000,
            "duration": 2000, "estimatedDuration": 2000, "displayName": "#16"
          },
          "lastFailedBuild": {
            "number": 15, "url": "https://jenkins.example.com/jenkins/job/mobile/15/",
            "result": "FAILURE", "building": false, "timestamp": 1699998000000,
            "duration": 3000, "estimatedDuration": 3000, "displayName": "#15"
          }
        }
        """#.utf8)
        let transport = MockHTTPTransport([
            .success(HTTPResponse(data: data, statusCode: 200, url: Samples.jobURL))
        ])
        let snapshot = try await JenkinsClient(transport: transport).fetchJob(
            url: Samples.jobURL,
            connection: Samples.connection()
        )
        #expect(snapshot.lastBuild?.number == 17)
        #expect(snapshot.lastCompletedBuild?.number == 16)
        #expect(snapshot.lastSuccessfulBuild?.number == 16)
        #expect(snapshot.lastFailedBuild?.number == 15)
        #expect(snapshot.buildHistory.map(\.number) == [17, 16, 15])
        #expect(snapshot.status == .unstable)
    }

    @Test("Jenkins client lazily decodes direct container children")
    func clientChildren() async throws {
        let data = Data(#"{"jobs":[{"name":"mobile","fullName":"team/mobile","url":"https://jenkins.example.com/jenkins/job/mobile/","color":"blue","_class":"org.jenkinsci.plugins.workflow.job.WorkflowJob","buildable":true}]}"#.utf8)
        let transport = MockHTTPTransport([.success(HTTPResponse(data: data, statusCode: 200, url: Samples.secondJobURL))])
        let children = try await JenkinsClient(transport: transport).fetchChildren(
            containerURL: Samples.secondJobURL,
            connection: Samples.connection()
        )
        #expect(children.first?.fullName == "team/mobile")
        #expect(children.first?.buildable == true)
        #expect(children.first?.isContainer == false)
    }

    @Test("Jenkins client maps HTTP and payload errors")
    func clientErrors() async throws {
        let cases: [(Int, JenkinsClientError)] = [
            (401, .authenticationRequired), (403, .forbidden), (404, .notFound),
            (500, .server(500)), (503, .server(503)), (418, .http(418))
        ]
        for (status, expected) in cases {
            let transport = MockHTTPTransport([.success(HTTPResponse(data: Data(), statusCode: status, url: nil))])
            let client = JenkinsClient(transport: transport)
            await #expect(throws: expected) {
                try await client.fetchJobs(connection: Samples.connection())
            }
            #expect(expected.errorDescription != nil)
        }

        let invalid = MockHTTPTransport([.success(HTTPResponse(data: Data("{}".utf8), statusCode: 200, url: nil))])
        await #expect(throws: JenkinsClientError.invalidPayload) {
            try await JenkinsClient(transport: invalid).fetchJobs(connection: Samples.connection())
        }
        let detailInvalid = MockHTTPTransport([.success(HTTPResponse(data: Data("[]".utf8), statusCode: 200, url: nil))])
        await #expect(throws: JenkinsClientError.invalidPayload) {
            try await JenkinsClient(transport: detailInvalid).fetchJob(url: Samples.jobURL, connection: Samples.connection())
        }
        let failing = MockHTTPTransport([.failure(JenkinsClientError.invalidResponse)])
        await #expect(throws: JenkinsClientError.invalidResponse) {
            try await JenkinsClient(transport: failing).fetchJobs(connection: Samples.connection())
        }
        #expect(JenkinsClientError.invalidResponse.errorDescription != nil)
        #expect(JenkinsClientError.invalidPayload.errorDescription != nil)
        #expect(JenkinsClientError.crossOrigin.errorDescription != nil)

        let transportErrors: [(URLError.Code, JenkinsClientError)] = [
            (.timedOut, .timeout),
            (.serverCertificateUntrusted, .tlsTrust),
            (.notConnectedToInternet, .networkUnavailable)
        ]
        for (code, expected) in transportErrors {
            let transport = MockHTTPTransport([.failure(URLError(code))])
            await #expect(throws: expected) {
                try await JenkinsClient(transport: transport).fetchJobs(connection: Samples.connection())
            }
            #expect(expected.errorDescription != nil)
        }
        let unknownFailure = MockHTTPTransport([.failure(NSError(domain: "test", code: 1))])
        await #expect(throws: JenkinsClientError.invalidResponse) {
            try await JenkinsClient(transport: unknownFailure).fetchJobs(connection: Samples.connection())
        }
    }

    @Test("Jenkins client refuses to attach credentials to cross-origin job URLs")
    func crossOriginJob() async throws {
        let transport = MockHTTPTransport([])
        let client = JenkinsClient(transport: transport)
        await #expect(throws: JenkinsClientError.crossOrigin) {
            try await client.fetchJob(
                url: Samples.url("https://other.example.com/job/mobile/"),
                connection: Samples.connection()
            )
        }
        #expect(await transport.recordedRequests().isEmpty)
    }

    @Test("Stub Jenkins service returns configured values")
    func stubService() async throws {
        let stub = StubJenkinsService(
            jobsResult: .success([Samples.job()]),
            children: [Samples.secondJobURL: .success([Samples.job()])],
            snapshots: [Samples.jobURL: .success(Samples.snapshot())]
        )
        #expect(try await stub.fetchJobs(connection: Samples.connection()).count == 1)
        #expect(try await stub.fetchChildren(containerURL: Samples.secondJobURL, connection: Samples.connection()).count == 1)
        #expect(try await stub.fetchJob(url: Samples.jobURL, connection: Samples.connection()).name == "mobile")
        await #expect(throws: JenkinsClientError.notFound) {
            try await stub.fetchJob(url: Samples.secondJobURL, connection: Samples.connection())
        }
    }

    @Test("App settings persist atomically and recover from invalid storage")
    @MainActor
    func settingsPersistence() throws {
        let storage = MemorySettingsStorage()
        let settings = AppSettings(storage: storage, storageKey: "test")
        #expect(settings.state == AppSettingsState())
        settings.update {
            $0.language = .german
            $0.jenkins.serverURL = "https://example.com"
            $0.jobDetailViewMode = .card
        }
        let restored = AppSettings(storage: storage, storageKey: "test")
        #expect(restored.state.language == .german)
        #expect(restored.resolvedLanguage == .german)
        #expect(restored.state.jobDetailViewMode == .card)
        var replacement = AppSettingsState()
        replacement.language = .japanese
        restored.replace(with: replacement)
        #expect(restored.state == replacement)

        storage.set(Data("not-json".utf8), forKey: "invalid")
        #expect(AppSettings(storage: storage, storageKey: "invalid").state == AppSettingsState())

        let defaultsName = "JenkinsBuddyTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: defaultsName))
        let defaultsStorage = UserDefaultsSettingsStorage(defaults: defaults)
        defaultsStorage.set(Data("value".utf8), forKey: "key")
        #expect(defaultsStorage.data(forKey: "key") == Data("value".utf8))
        defaults.removePersistentDomain(forName: defaultsName)
    }

    @Test("Memory credentials save and delete tokens")
    func credentials() throws {
        let credentials: any CredentialStore = MemoryCredentialStore()
        let key = try Samples.credentialKey()
        #expect(try credentials.token(for: key) == nil)
        try credentials.save(token: "secret", for: key)
        #expect(try credentials.token(for: key) == "secret")
        try credentials.deleteToken(for: key)
        #expect(try credentials.token(for: key) == nil)
        #expect(CredentialStoreError.invalidData == .invalidData)
        #expect(CredentialStoreError.unexpectedStatus(-1) == .unexpectedStatus(-1))
    }

    @Test("Keychain credentials add, update, read, and remove tokens")
    func keychainCredentials() throws {
        let store = KeychainCredentialStore(
            service: "JenkinsBuddyTests-\(UUID().uuidString)"
        )
        let key = try Samples.credentialKey()
        try store.deleteToken(for: key)
        #expect(try store.token(for: key) == nil)
        try store.save(token: "first", for: key)
        #expect(try store.token(for: key) == "first")
        try store.save(token: "second", for: key)
        #expect(try store.token(for: key) == "second")
        try store.deleteToken(for: key)
        #expect(try store.token(for: key) == nil)
    }

    @Test("SQLite and memory stores round-trip normalized sessions")
    func stateStores() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: "JenkinsBuddyTests-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = SQLiteAppStateStore(path: directory.appending(path: "state.sqlite").path)
        #expect(try await store.load() == .initial)
        let tab = AppTab.job(title: "mobile", url: Samples.jobURL)
        let state = AppSessionState(tabs: [tab], selectedTabID: tab.id)
        try await store.save(state)
        let restored = try await store.load()
        #expect(restored.tabs == [.jobs, tab])
        #expect(restored.selectedTabID == tab.id)

        let memory: any AppStateStore = MemoryAppStateStore(state: state)
        #expect(try await memory.load() == state)
        try await memory.save(.initial)
        #expect(try await memory.load() == .initial)
    }

    @Test("Event detection emits only meaningful transitions")
    func eventDetection() {
        let detector = BuildEventDetector()
        let success = BuildObservation(number: 1, status: .success)
        #expect(detector.events(previous: success, current: success, jobName: "job", jobURL: Samples.jobURL).isEmpty)
        #expect(detector.events(previous: success, current: .init(number: 1, status: .building), jobName: "job", jobURL: Samples.jobURL).isEmpty)
        #expect(detector.events(previous: success, current: .init(number: 2, status: .building), jobName: "job", jobURL: Samples.jobURL).first?.kind == .started)
        #expect(detector.events(previous: .init(number: 2, status: .building), current: .init(number: 2, status: .building), jobName: "job", jobURL: Samples.jobURL).isEmpty)
        #expect(detector.events(previous: success, current: .init(number: 2, status: .success), jobName: "job", jobURL: Samples.jobURL).first?.kind == .succeeded)
        #expect(detector.events(previous: .init(number: 1, status: .failure), current: .init(number: 2, status: .success), jobName: "job", jobURL: Samples.jobURL).first?.kind == .succeeded)
        #expect(detector.events(previous: success, current: .init(number: 2, status: .failure), jobName: "job", jobURL: Samples.jobURL).first?.kind == .failed)
        #expect(detector.events(previous: success, current: .init(number: 2, status: .unstable), jobName: "job", jobURL: Samples.jobURL).first?.kind == .unstable)
        #expect(detector.events(previous: success, current: .init(number: 2, status: .aborted), jobName: "job", jobURL: Samples.jobURL).isEmpty)
    }

    @Test("Monitor establishes a silent baseline and prunes closed jobs")
    func monitor() async {
        let monitor = JobMonitor()
        #expect(await monitor.record(Samples.snapshot()).isEmpty)
        let failed = Samples.snapshot(number: 43, result: "FAILURE")
        #expect(await monitor.record(failed).first?.kind == .failed)
        #expect(await monitor.observation(for: Samples.jobURL)?.number == 43)
        await monitor.remove(urlsToKeep: [])
        #expect(await monitor.observation(for: Samples.jobURL) == nil)
        _ = await monitor.record(Samples.snapshot())
        await monitor.reset()
        #expect(await monitor.observation(for: Samples.jobURL) == nil)
    }

    @Test("Polling backoff clamps inputs and caps exponential delay")
    func pollingBackoff() {
        let backoff = PollingBackoff(baseInterval: 0, maximumInterval: 10)
        #expect(backoff.baseInterval == 1)
        #expect(backoff.maximumInterval == 10)
        #expect(backoff.delay(afterConsecutiveFailures: 0) == 1)
        #expect(backoff.delay(afterConsecutiveFailures: 1) == 2)
        #expect(backoff.delay(afterConsecutiveFailures: 20) == 10)
        let clampedMaximum = PollingBackoff(baseInterval: 30, maximumInterval: 5)
        #expect(clampedMaximum.maximumInterval == 30)
    }

    @Test("Memory notifications record authorization and delivery")
    func memoryNotifications() async throws {
        let service = MemoryNotificationService()
        #expect(await service.requestAuthorization())
        let event = BuildEvent(kind: .failed, jobName: "mobile", jobURL: Samples.jobURL, buildNumber: 9)
        await service.deliver(event, title: "title", body: "body", playSound: false)
        let delivery = try #require(await service.recordedDeliveries().first)
        #expect(delivery.event == event)
        #expect(delivery.title == "title")
        #expect(delivery.body == "body")
        #expect(!delivery.playSound)
        #expect(NotificationIdentity.identifier(for: event) == NotificationIdentity.identifier(for: event))
        #expect(NotificationIdentity.threadIdentifier(for: Samples.jobURL).count == 64)
        let content = NotificationPayload.content(
            for: event,
            title: "mobile",
            body: "Build #9 failed",
            playSound: true
        )
        #expect(content.title == "mobile")
        #expect(content.sound != nil)
        #expect(content.userInfo["buildNumber"] as? Int == 9)
        let noNumber = BuildEvent(kind: .succeeded, jobName: "mobile", jobURL: Samples.jobURL, buildNumber: nil)
        let silentContent = NotificationPayload.content(for: noNumber, title: "mobile", body: "done", playSound: false)
        #expect(silentContent.sound == nil)
        #expect(silentContent.userInfo["buildNumber"] == nil)
    }

    @Test("Event bus posts both commands")
    @MainActor
    func eventBus() async {
        let settingsReceived = LockedFlag()
        let refreshReceived = LockedFlag()
        let connectionChanged = LockedFlag()
        let openJob = LockedFlag()
        let center = NotificationCenter()
        let settingsToken = center.addObserver(forName: .showJenkinsBuddySettings, object: nil, queue: nil) { _ in
            settingsReceived.set()
        }
        let refreshToken = center.addObserver(forName: .refreshJenkinsBuddy, object: nil, queue: nil) { _ in
            refreshReceived.set()
        }
        let connectionToken = center.addObserver(forName: .jenkinsBuddyConnectionChanged, object: nil, queue: nil) { _ in connectionChanged.set() }
        let openToken = center.addObserver(forName: .openJenkinsBuddyJob, object: nil, queue: nil) { _ in openJob.set() }
        AppEventBus.showSettings(center: center)
        AppEventBus.refresh(center: center)
        AppEventBus.connectionChanged(center: center)
        AppEventBus.openJob(OpenJobEvent(jobURL: Samples.jobURL, jobName: "mobile"), center: center)
        #expect(settingsReceived.value)
        #expect(refreshReceived.value)
        #expect(connectionChanged.value)
        #expect(openJob.value)
        center.removeObserver(settingsToken)
        center.removeObserver(refreshToken)
        center.removeObserver(connectionToken)
        center.removeObserver(openToken)
    }

    @Test("Notification responses decode safe job routes")
    @MainActor
    func notificationRoutes() {
        let event = NotificationResponseRoute.event(from: [
            "jobURL": Samples.jobURL.absoluteString,
            "jobName": "mobile"
        ])
        #expect(event?.jobURL == Samples.jobURL)
        #expect(event?.jobName == "mobile")
        #expect(NotificationResponseRoute.event(from: [:]) == nil)
        #expect(ForegroundNotificationPresentation.options.contains(.banner))
        #expect(AppDelegate().applicationShouldTerminateAfterLastWindowClosed(NSApplication.shared))
    }
}
