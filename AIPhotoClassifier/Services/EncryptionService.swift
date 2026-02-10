import Foundation
import CryptoKit
import Security

enum EncryptionError: Error {
    case encryptionFailed
    case decryptionFailed
    case keyGenerationFailed
    case keychainError(OSStatus)
    case invalidData
}

class EncryptionService {
    static let shared = EncryptionService()

    private init() {}

    // MARK: - Master Key Management
    func getMasterKey() throws -> SymmetricKey {
        // Try to retrieve existing key from Keychain
        if let keyData = try? retrieveKeyFromKeychain() {
            if let key = SymmetricKey(data: keyData) {
                return key
            }
        }

        // Generate new key if not found
        let newKey = SymmetricKey(size: .bits256)
        try saveKeyToKeychain(newKey.dataRepresentation)
        return newKey
    }

    // MARK: - Image Encryption/Decryption
    func encryptImage(_ imageData: Data) throws -> Data {
        let key = try getMasterKey()
        return try encrypt(imageData, with: key)
    }

    func decryptImage(_ encryptedData: Data) throws -> Data {
        let key = try getMasterKey()
        return try decrypt(encryptedData, with: key)
    }

    // MARK: - Generic Encryption/Decryption
    func encrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            guard let combined = sealedBox.combined else {
                throw EncryptionError.encryptionFailed
            }
            return combined
        } catch {
            throw EncryptionError.encryptionFailed
        }
    }

    func decrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return decryptedData
        } catch {
            throw EncryptionError.decryptionFailed
        }
    }

    // MARK: - Keychain Operations
    private func saveKeyToKeychain(_ keyData: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.Encryption.keychainService,
            kSecAttrAccount as String: Constants.Encryption.masterKeyIdentifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing key first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw EncryptionError.keychainError(status)
        }
    }

    private func retrieveKeyFromKeychain() throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.Encryption.keychainService,
            kSecAttrAccount as String: Constants.Encryption.masterKeyIdentifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let keyData = result as? Data else {
            throw EncryptionError.keychainError(status)
        }

        return keyData
    }

    func deleteAllKeys() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.Encryption.keychainService
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw EncryptionError.keychainError(status)
        }
    }
}
