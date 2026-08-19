import Foundation
import Security

enum CredentialStoreError: Error, Equatable {
    case unexpectedStatus(OSStatus)
    case invalidData
}

protocol CredentialStore: Sendable {
    func token(for key: CredentialKey) throws -> String?
    func save(token: String, for key: CredentialKey) throws
    func deleteToken(for key: CredentialKey) throws
}

struct KeychainCredentialStore: CredentialStore, Sendable {
    let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "com.caoccao.jenkins-buddy") {
        self.service = service
    }

    func token(for key: CredentialKey) throws -> String? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw CredentialStoreError.unexpectedStatus(status) }
        guard let data = result as? Data, let value = String(data: data, encoding: .utf8) else {
            throw CredentialStoreError.invalidData
        }
        return value
    }

    func save(token: String, for key: CredentialKey) throws {
        let data = Data(token.utf8)
        let status = SecItemUpdate(
            baseQuery(for: key) as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )
        if status == errSecItemNotFound {
            var query = baseQuery(for: key)
            query[kSecValueData as String] = data
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw CredentialStoreError.unexpectedStatus(addStatus)
            }
            return
        }
        guard status == errSecSuccess else { throw CredentialStoreError.unexpectedStatus(status) }
    }

    func deleteToken(for key: CredentialKey) throws {
        let status = SecItemDelete(baseQuery(for: key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CredentialStoreError.unexpectedStatus(status)
        }
    }

    private func baseQuery(for key: CredentialKey) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.account
        ]
    }
}

final class MemoryCredentialStore: CredentialStore, @unchecked Sendable {
    private let lock = NSLock()
    private var values: [CredentialKey: String] = [:]
    private let fallbackToken: String?

    init(token: String? = nil) {
        fallbackToken = token
    }

    func token(for key: CredentialKey) -> String? {
        lock.withLock { values[key] ?? fallbackToken }
    }

    func save(token: String, for key: CredentialKey) {
        lock.withLock { values[key] = token }
    }

    func deleteToken(for key: CredentialKey) {
        lock.withLock { values[key] = nil }
    }
}
