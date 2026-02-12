import SwiftUI
import UIKit
import CryptoKit

// MARK: - Data Extensions
extension Data {
    func sha256Hash() -> String {
        let hash = SHA256.hash(data: self)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - String Extensions
extension String {
    func sha256() -> String {
        guard let data = self.data(using: .utf8) else { return "" }
        return data.sha256Hash()
    }

    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }
}

// MARK: - UIImage Extensions
extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }

    /// Resize for API analysis: max 1024px on longest side, JPEG quality 0.6
    func toBase64ForAPI(maxDimension: CGFloat = 1024, quality: CGFloat = 0.6) -> String? {
        let resized = resizedToFit(maxDimension: maxDimension) ?? self
        guard let data = resized.jpegData(compressionQuality: quality) else { return nil }
        return data.base64EncodedString()
    }

    func resizedToFit(maxDimension: CGFloat) -> UIImage? {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        return resized(to: newSize)
    }

    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func thumbnail(size: CGFloat = Constants.UI.thumbnailSize) -> UIImage? {
        let targetSize = CGSize(width: size, height: size)
        return resized(to: targetSize)
    }
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Color Extensions
extension Color {
    static let appPrimary = Color.blue
    static let appSecondary = Color.purple
    static let appBackground = Color(UIColor.systemBackground)
    static let appSecondaryBackground = Color(UIColor.secondarySystemBackground)
}

// MARK: - Date Extensions
extension Date {
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }
}

// MARK: - SymmetricKey Extensions
extension SymmetricKey {
    /// Validate data length before creating a key. Uses a different parameter
    /// name to avoid infinite recursion with self.init(data:).
    static func validated(from keyData: Data) -> SymmetricKey? {
        guard keyData.count == SymmetricKeySize.bits256.bitCount / 8 else { return nil }
        return SymmetricKey(data: keyData)
    }

    var dataRepresentation: Data {
        return withUnsafeBytes { Data($0) }
    }
}
