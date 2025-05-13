//
//  KeychainService.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import Foundation
import KeychainAccess

protocol KeychainServiceProtocol {
    func saveAPIKey(_ key: String) -> Bool
    func getAPIKey() -> String?
    func deleteAPIKey() -> Bool
}

class KeychainService: KeychainServiceProtocol {

    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.example.weatherapp.keychain")
    private let apiKeyKey = "weatherAPIKey"

    func saveAPIKey(_ key: String) -> Bool {
        do {
            try keychain.set(key, key: apiKeyKey)
            print("KeychainService: API Key successfully saved.")
            return true
        } catch let error {
            print("KeychainService: Error saving API Key: \(error.localizedDescription)")
            return false
        }
    }

    func getAPIKey() -> String? {
        do {
            let key = try keychain.get(apiKeyKey)
            if key != nil {
                 print("KeychainService: API Key successfully retrieved.")
            } else {
                 print("KeychainService: API Key not found in Keychain.")
            }
            return key
        } catch let error {
            print("KeychainService: Error retrieving API Key: \(error.localizedDescription)")
            return nil
        }
    }

    func deleteAPIKey() -> Bool {
        do {
            try keychain.remove(apiKeyKey)
            return true
        } catch let error {
            print("KeychainService: Error deleting API Key: \(error.localizedDescription)")
            return false
        }
    }
}
