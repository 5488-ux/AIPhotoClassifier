import Foundation
import UIKit

enum StorageError: Error {
    case saveFailed
    case loadFailed
    case deleteFailed
    case notFound
}

class StorageService {
    static let shared = StorageService()

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Directory URLs
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var albumsDirectory: URL {
        let url = documentsDirectory.appendingPathComponent("Albums")
        createDirectoryIfNeeded(url)
        return url
    }

    private var photosDirectory: URL {
        let url = documentsDirectory.appendingPathComponent("Photos")
        createDirectoryIfNeeded(url)
        return url
    }

    private var chatHistoryURL: URL {
        documentsDirectory.appendingPathComponent("chat_history.json")
    }

    // MARK: - Albums Management
    func saveAlbums(_ albums: [Album]) throws {
        let url = albumsDirectory.appendingPathComponent("albums.json")
        let data = try encoder.encode(albums)
        try data.write(to: url)
    }

    func loadAlbums() throws -> [Album] {
        let url = albumsDirectory.appendingPathComponent("albums.json")

        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode([Album].self, from: data)
    }

    // MARK: - Photos Management
    func savePhoto(_ photo: Photo, imageData: Data, albumID: UUID) throws -> String {
        // Encrypt image data
        let encryptedData = try EncryptionService.shared.encryptImage(imageData)

        // Generate file path
        let fileName = "\(photo.id.uuidString).enc"
        let fileURL = photosDirectory.appendingPathComponent(fileName)

        // Save encrypted data
        try encryptedData.write(to: fileURL)

        return fileName
    }

    func loadPhotoImage(from path: String) throws -> UIImage {
        let fileURL = photosDirectory.appendingPathComponent(path)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw StorageError.notFound
        }

        let encryptedData = try Data(contentsOf: fileURL)
        let decryptedData = try EncryptionService.shared.decryptImage(encryptedData)

        guard let image = UIImage(data: decryptedData) else {
            throw StorageError.loadFailed
        }

        return image
    }

    func deletePhoto(at path: String) throws {
        let fileURL = photosDirectory.appendingPathComponent(path)
        try fileManager.removeItem(at: fileURL)
    }

    func savePhotos(_ photos: [Photo], for albumID: UUID) throws {
        let fileName = "\(albumID.uuidString)_photos.json"
        let url = photosDirectory.appendingPathComponent(fileName)
        let data = try encoder.encode(photos)
        try data.write(to: url)
    }

    func loadPhotos(for albumID: UUID) throws -> [Photo] {
        let fileName = "\(albumID.uuidString)_photos.json"
        let url = photosDirectory.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode([Photo].self, from: data)
    }

    // MARK: - Chat History Management
    func saveChatHistory(_ messages: [AIMessage]) throws {
        let data = try encoder.encode(messages)
        try data.write(to: chatHistoryURL)
    }

    func loadChatHistory() throws -> [AIMessage] {
        guard fileManager.fileExists(atPath: chatHistoryURL.path) else {
            return []
        }

        let data = try Data(contentsOf: chatHistoryURL)
        return try decoder.decode([AIMessage].self, from: data)
    }

    func clearChatHistory() throws {
        if fileManager.fileExists(atPath: chatHistoryURL.path) {
            try fileManager.removeItem(at: chatHistoryURL)
        }
    }

    // MARK: - Helper Methods
    private func createDirectoryIfNeeded(_ url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    func clearAllData() throws {
        try fileManager.removeItem(at: albumsDirectory)
        try fileManager.removeItem(at: photosDirectory)
        try? fileManager.removeItem(at: chatHistoryURL)

        createDirectoryIfNeeded(albumsDirectory)
        createDirectoryIfNeeded(photosDirectory)
    }
}
