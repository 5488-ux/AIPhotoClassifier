import Foundation
import UIKit

class ImageClassificationService {
    static let shared = ImageClassificationService()

    private init() {}

    // MARK: - Classify and Save Images
    func classifyAndSaveImages(_ images: [UIImage], existingAlbums: [Album]) async throws -> [Album] {
        // Step 1: Analyze images using Claude API
        let classification = try await ClaudeAPIService.shared.analyzeImages(images)

        // Step 2: Create or match albums
        var updatedAlbums = existingAlbums
        var albumPhotosMap: [UUID: [Photo]] = [:]

        for (categoryName, imageIndices) in classification {
            // Find or create album
            let album: Album
            if let existingAlbum = updatedAlbums.first(where: { $0.category == categoryName || $0.name == categoryName }) {
                album = existingAlbum
            } else {
                // Create new album
                let newAlbum = Album(
                    name: categoryName,
                    category: categoryName
                )
                updatedAlbums.append(newAlbum)
                album = newAlbum
            }

            // Step 3: Save images to album
            var photos: [Photo] = []

            for index in imageIndices {
                guard index < images.count else { continue }

                let image = images[index]

                // Create thumbnail
                let thumbnailImage = image.thumbnail() ?? image
                let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.7)

                // Create photo object
                let photo = Photo(
                    encryptedDataPath: "", // Will be set after saving
                    thumbnailData: thumbnailData,
                    albumID: album.id,
                    originalFileName: "photo_\(Date().timeIntervalSince1970).jpg"
                )

                // Save encrypted image
                if let imageData = image.jpegData(compressionQuality: 0.9) {
                    let path = try StorageService.shared.savePhoto(
                        photo,
                        imageData: imageData,
                        albumID: album.id
                    )

                    var updatedPhoto = photo
                    updatedPhoto.encryptedDataPath = path
                    photos.append(updatedPhoto)
                }
            }

            // Store photos for this album
            if albumPhotosMap[album.id] != nil {
                albumPhotosMap[album.id]?.append(contentsOf: photos)
            } else {
                albumPhotosMap[album.id] = photos
            }
        }

        // Step 4: Save all photos to storage
        for (albumID, photos) in albumPhotosMap {
            var existingPhotos = (try? StorageService.shared.loadPhotos(for: albumID)) ?? []
            existingPhotos.append(contentsOf: photos)
            try StorageService.shared.savePhotos(existingPhotos, for: albumID)

            // Update album cover if needed
            if let albumIndex = updatedAlbums.firstIndex(where: { $0.id == albumID }),
               updatedAlbums[albumIndex].coverPhotoID == nil,
               let firstPhoto = photos.first {
                updatedAlbums[albumIndex].coverPhotoID = firstPhoto.id
            }
        }

        // Step 5: Save updated albums
        try StorageService.shared.saveAlbums(updatedAlbums)

        return updatedAlbums
    }

    // MARK: - Add Images to Specific Album
    func addImagesToAlbum(_ images: [UIImage], album: Album) async throws -> [Photo] {
        var photos: [Photo] = []

        for image in images {
            // Create thumbnail
            let thumbnailImage = image.thumbnail() ?? image
            let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.7)

            // Create photo object
            let photo = Photo(
                encryptedDataPath: "",
                thumbnailData: thumbnailData,
                albumID: album.id,
                originalFileName: "photo_\(Date().timeIntervalSince1970).jpg"
            )

            // Save encrypted image
            if let imageData = image.jpegData(compressionQuality: 0.9) {
                let path = try StorageService.shared.savePhoto(
                    photo,
                    imageData: imageData,
                    albumID: album.id
                )

                var updatedPhoto = photo
                updatedPhoto.encryptedDataPath = path
                photos.append(updatedPhoto)
            }
        }

        // Save photos
        var existingPhotos = (try? StorageService.shared.loadPhotos(for: album.id)) ?? []
        existingPhotos.append(contentsOf: photos)
        try StorageService.shared.savePhotos(existingPhotos, for: album.id)

        return photos
    }
}
