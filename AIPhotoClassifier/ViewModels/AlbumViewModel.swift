import Foundation
import SwiftUI

@MainActor
class AlbumViewModel: ObservableObject {
    @Published var album: Album
    @Published var photos: [Photo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var isUnlocked = false

    init(album: Album) {
        self.album = album
        self.isUnlocked = !album.isEncrypted
        if isUnlocked {
            loadPhotos()
        }
    }

    func unlockAlbum(password: String) -> Bool {
        if album.verifyPassword(password) {
            isUnlocked = true
            loadPhotos()
            return true
        }
        return false
    }

    func lockAlbum() {
        isUnlocked = false
        photos.removeAll()
    }

    func loadPhotos() {
        guard isUnlocked else { return }

        do {
            photos = try StorageService.shared.loadPhotos(for: album.id)
        } catch {
            handleError(error)
        }
    }

    func loadImage(for photo: Photo) -> UIImage? {
        do {
            return try StorageService.shared.loadPhotoImage(from: photo.encryptedDataPath)
        } catch {
            handleError(error)
            return nil
        }
    }

    func deletePhoto(_ photo: Photo) {
        photos.removeAll { $0.id == photo.id }

        do {
            try StorageService.shared.deletePhoto(at: photo.encryptedDataPath)
            try StorageService.shared.savePhotos(photos, for: album.id)
        } catch {
            handleError(error)
        }
    }

    func setPassword(_ password: String) {
        album.setPassword(password)
        saveAlbum()
    }

    func removePassword() {
        album.removePassword()
        isUnlocked = true
        saveAlbum()
    }

    private func saveAlbum() {
        do {
            var albums = try StorageService.shared.loadAlbums()
            if let index = albums.firstIndex(where: { $0.id == album.id }) {
                albums[index] = album
                try StorageService.shared.saveAlbums(albums)
            }
        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
