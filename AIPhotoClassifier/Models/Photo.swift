import Foundation
import SwiftUI

struct Photo: Identifiable, Codable {
    let id: UUID
    var encryptedDataPath: String
    var thumbnailData: Data?
    var albumID: UUID
    var uploadedAt: Date
    var originalFileName: String

    init(id: UUID = UUID(),
         encryptedDataPath: String,
         thumbnailData: Data? = nil,
         albumID: UUID,
         uploadedAt: Date = Date(),
         originalFileName: String = "") {
        self.id = id
        self.encryptedDataPath = encryptedDataPath
        self.thumbnailData = thumbnailData
        self.albumID = albumID
        self.uploadedAt = uploadedAt
        self.originalFileName = originalFileName
    }

    var thumbnail: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
}
