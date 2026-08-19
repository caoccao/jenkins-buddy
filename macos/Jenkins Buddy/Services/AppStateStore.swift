import Foundation
import SQLite3

protocol AppStateStore: Sendable {
    func load() async throws -> AppSessionState
    func save(_ state: AppSessionState) async throws
}

enum AppStateStoreError: Error, Equatable {
    case openDatabase(String)
    case execute(String)
    case encode
    case decode
}

actor SQLiteAppStateStore: AppStateStore {
    nonisolated(unsafe) private var database: OpaquePointer?
    private let path: String

    init(path: String) {
        self.path = path
    }

    static func defaultStore(fileManager: FileManager = .default) throws -> SQLiteAppStateStore {
        let base = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = base.appending(path: "Jenkins Buddy", directoryHint: .isDirectory)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return SQLiteAppStateStore(path: directory.appending(path: "AppState.sqlite").path)
    }

    deinit {
        sqlite3_close(database)
    }

    func load() throws -> AppSessionState {
        try ensureOpen()
        let sql = "SELECT payload FROM app_state WHERE id = 1"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            throw AppStateStoreError.execute(lastError)
        }
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW else { return .initial }
        guard let bytes = sqlite3_column_blob(statement, 0) else { return .initial }
        let count = Int(sqlite3_column_bytes(statement, 0))
        let data = Data(bytes: bytes, count: count)
        guard let state = try? JSONDecoder().decode(AppSessionState.self, from: data) else { return .initial }
        return state.normalized()
    }

    func save(_ state: AppSessionState) throws {
        try ensureOpen()
        guard let data = try? JSONEncoder().encode(state.normalized()) else {
            throw AppStateStoreError.encode
        }
        let sql = "INSERT OR REPLACE INTO app_state (id, payload) VALUES (1, ?)"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            throw AppStateStoreError.execute(lastError)
        }
        defer { sqlite3_finalize(statement) }
        let result = data.withUnsafeBytes { bytes in
            let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            return sqlite3_bind_blob(statement, 1, bytes.baseAddress, Int32(data.count), transient)
        }
        guard result == SQLITE_OK, sqlite3_step(statement) == SQLITE_DONE else {
            throw AppStateStoreError.execute(lastError)
        }
    }

    private func ensureOpen() throws {
        guard database == nil else { return }
        guard sqlite3_open(path, &database) == SQLITE_OK else {
            throw AppStateStoreError.openDatabase(lastError)
        }
        try execute("CREATE TABLE IF NOT EXISTS app_state (id INTEGER PRIMARY KEY CHECK (id = 1), payload BLOB NOT NULL)")
    }

    private func execute(_ sql: String) throws {
        var errorMessage: UnsafeMutablePointer<CChar>?
        guard sqlite3_exec(database, sql, nil, nil, &errorMessage) == SQLITE_OK else {
            let message = errorMessage.map { String(cString: $0) } ?? lastError
            sqlite3_free(errorMessage)
            throw AppStateStoreError.execute(message)
        }
    }

    private var lastError: String {
        database.map { String(cString: sqlite3_errmsg($0)) } ?? "Unknown SQLite error"
    }
}

actor MemoryAppStateStore: AppStateStore {
    private var state: AppSessionState

    init(state: AppSessionState = .initial) {
        self.state = state
    }

    func load() -> AppSessionState { state }
    func save(_ state: AppSessionState) { self.state = state }
}
