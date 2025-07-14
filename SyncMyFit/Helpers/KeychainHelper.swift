//
//  KeychainHelper.swift
//  SyncMyFit
//
//  Created by Baranidharan Pasupathi on 2025-07-06.
//

import Foundation
import Security

// MARK: - KeychainHelper

/// Provides utility functions for securely storing, retrieving, and deleting data using the iOS Keychain.
class KeychainHelper {
    
    // MARK: - Singleton

    /// Shared instance for centralized access.
    static let shared = KeychainHelper()

    /// Private initializer to enforce singleton usage.
    private init() {}

    // MARK: - Save to Keychain

    /// Saves data to the keychain for the specified service and account.
    /// If an existing entry exists, it is replaced.
    ///
    /// - Parameters:
    ///   - data: The data to store.
    ///   - service: A string representing the service (e.g., "fitbit_token").
    ///   - account: A string representing the account identifier (e.g., "user123").
    /// - Returns: A boolean indicating success or failure.
    @discardableResult
    func save(_ data: Data, service: String, account: String) -> Bool {
        let query: CFDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data
        ] as CFDictionary

        // Remove any existing item before saving
        SecItemDelete(query)

        let status = SecItemAdd(query, nil)

        if status != errSecSuccess {
            print("🔐 Keychain save error: \(status)")
            return false
        }

        return true
    }

    // MARK: - Read from Keychain

    /// Retrieves data from the keychain for the specified service and account.
    ///
    /// - Parameters:
    ///   - service: The service identifier used when saving.
    ///   - account: The account identifier used when saving.
    /// - Returns: The stored `Data` object, or `nil` if not found or on error.
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

    // MARK: - Delete from Keychain

    /// Deletes the keychain entry for the given service and account.
    ///
    /// - Parameters:
    ///   - service: The service identifier.
    ///   - account: The account identifier.
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
