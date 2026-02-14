import Foundation
import SwiftUI

struct Album: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: String
    var isEncrypted: Bool
    var passwordHash: String?
    var createdAt: Date
    var coverPhotoID: UUID?

    init(id: UUID = UUID(),
         name: String,
         category: String,
         isEncrypted: Bool = false,
         passwordHash: String? = nil,
         createdAt: Date = Date(),
         coverPhotoID: UUID? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.isEncrypted = isEncrypted
        self.passwordHash = passwordHash
        self.createdAt = createdAt
        self.coverPhotoID = coverPhotoID
    }

    func verifyPassword(_ password: String) -> Bool {
        guard let hash = passwordHash else { return true }
        return password.sha256() == hash
    }

    mutating func setPassword(_ password: String) {
        self.passwordHash = password.sha256()
        self.isEncrypted = true
    }

    mutating func removePassword() {
        self.passwordHash = nil
        self.isEncrypted = false
    }
}
