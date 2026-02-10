import Foundation
import SwiftUI
import PhotosUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var albums: [Album] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    init() {
        loadAlbums()
    }

    func loadAlbums() {
        do {
            albums = try StorageService.shared.loadAlbums()
        } catch {
            handleError(error)
        }
    }

    func uploadImages(_ images: [UIImage]) async {
        isLoading = true
        defer { isLoading = false }

        do {
            albums = try await ImageClassificationService.shared.classifyAndSaveImages(
                images,
                existingAlbums: albums
            )
        } catch {
            handleError(error)
        }
    }

    func createAlbum(name: String, category: String) {
        let newAlbum = Album(name: name, category: category)
        albums.append(newAlbum)

        do {
            try StorageService.shared.saveAlbums(albums)
        } catch {
            handleError(error)
        }
    }

    func deleteAlbum(_ album: Album) {
        albums.removeAll { $0.id == album.id }

        do {
            try StorageService.shared.saveAlbums(albums)
            // Also delete all photos in the album
            let photos = try StorageService.shared.loadPhotos(for: album.id)
            for photo in photos {
                try? StorageService.shared.deletePhoto(at: photo.encryptedDataPath)
            }
        } catch {
            handleError(error)
        }
    }

    func updateAlbum(_ album: Album) {
        if let index = albums.firstIndex(where: { $0.id == album.id }) {
            albums[index] = album

            do {
                try StorageService.shared.saveAlbums(albums)
            } catch {
                handleError(error)
            }
        }
    }

    func getAlbumPhotos(_ album: Album) -> [Photo] {
        do {
            return try StorageService.shared.loadPhotos(for: album.id)
        } catch {
            handleError(error)
            return []
        }
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
