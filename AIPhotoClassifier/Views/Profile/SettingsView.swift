import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showClearDataConfirm = false
    @AppStorage("autoLockEnabled") private var autoLockEnabled = true
    @AppStorage("thinkingModeDefault") private var thinkingModeDefault = true

    var body: some View {
        NavigationStack {
            List {
                Section("安全设置") {
                    Toggle("自动锁定", isOn: $autoLockEnabled)
                    LabeledContent("认证方式", value: AuthenticationService.shared.getBiometryTypeString())
                }

                Section("AI 设置") {
                    Toggle("默认启用思考模式", isOn: $thinkingModeDefault)
                    LabeledContent("AI 模型", value: "Claude Haiku 4.5")
                }

                Section("存储管理") {
                    LabeledContent("已用空间", value: getStorageSize())

                    Button(role: .destructive) { showClearDataConfirm = true } label: {
                        Label("清除所有数据", systemImage: "trash.fill")
                    }
                }

                Section {
                    LabeledContent("应用版本", value: "1.0.0")
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .confirmationDialog("清除所有数据", isPresented: $showClearDataConfirm, titleVisibility: .visible) {
                Button("清除", role: .destructive) { clearAllData() }
            } message: {
                Text("此操作将删除所有收藏夹、照片和聊天记录，且无法恢复")
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
