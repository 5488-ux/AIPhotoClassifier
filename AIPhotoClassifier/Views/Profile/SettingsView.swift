import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showClearDataConfirm = false
    @AppStorage("autoLockEnabled") private var autoLockEnabled = true
    @AppStorage("thinkingModeDefault") private var thinkingModeDefault = true

    var body: some View {
        NavigationView {
            List {
                Section("安全设置") {
                    Toggle("自动锁定", isOn: $autoLockEnabled)

                    HStack {
                        Text("认证方式")
                        Spacer()
                        Text(AuthenticationService.shared.getBiometryTypeString())
                            .foregroundColor(.secondary)
                    }
                }

                Section("AI设置") {
                    Toggle("默认启用思考模式", isOn: $thinkingModeDefault)

                    HStack {
                        Text("AI模型")
                        Spacer()
                        Text("Claude Haiku 4.5")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }

                Section("存储管理") {
                    HStack {
                        Text("已用空间")
                        Spacer()
                        Text(getStorageSize())
                            .foregroundColor(.secondary)
                    }

                    Button(role: .destructive, action: { showClearDataConfirm = true }) {
                        Label("清除所有数据", systemImage: "trash.fill")
                    }
                }

                Section {
                    HStack {
                        Text("应用版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("清除所有数据", isPresented: $showClearDataConfirm, titleVisibility: .visible) {
                Button("清除", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("此操作将删除所有收藏夹、照片和聊天记录,且无法恢复")
            }
        }
    }

    private func getStorageSize() -> String {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "未知"
        }

        var totalSize: Int64 = 0

        if let enumerator = fileManager.enumerator(at: documentsURL, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }

        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }

    private func clearAllData() {
        do {
            try StorageService.shared.clearAllData()
            try EncryptionService.shared.deleteAllKeys()
            dismiss()
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
}
