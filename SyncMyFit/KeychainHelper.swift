//
//  KeychainHelper.swift
//  SyncMyFit
//
//  Created by Baranidharan Pasupathi on 2025-07-06.
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()

    private init() {}

    @discardableResult
    func save(_ data: Data, service: String, account: String) -> Bool {
        let query: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data
        ] as CFDictionary

        SecItemDelete(query) // Ensure only one exists
        let status = SecItemAdd(query, nil)

        if status != errSecSuccess {
            print("🔐 Keychain save error: \(status)")
            return false
        }
        return true
    }

    func read(service: String, account: String) -> Data? {
        let query: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        if status != errSecSuccess {
            print("🔐 Keychain read error: \(status)")
            return nil
        }

        return result as? Data
    }

    func delete(service: String, account: String) {
        let query: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary

        let status = SecItemDelete(query)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("🔐 Keychain delete error: \(status)")
        }
    }
}
