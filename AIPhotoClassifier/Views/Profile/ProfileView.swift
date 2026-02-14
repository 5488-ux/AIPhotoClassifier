import SwiftUI

struct ProfileView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var showLogoutConfirm = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 52))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.appPrimary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("用户")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("已通过\(authService.getBiometryTypeString())认证")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("数据统计") {
                    LabeledContent {
                        Text("\(getAlbumCount())")
                            .foregroundStyle(.secondary)
                    } label: {
                        Label("收藏夹数量", systemImage: "folder.fill")
                    }

                    LabeledContent {
                        Text("\(getTotalPhotoCount())")
                            .foregroundStyle(.secondary)
                    } label: {
                        Label("总照片数", systemImage: "photo.fill")
                    }
                }

                Section("设置") {
                    Button { showSettings = true } label: {
                        Label("应用设置", systemImage: "gearshape")
                    }

                    NavigationLink(destination: AboutView()) {
                        Label("关于", systemImage: "info.circle")
                    }
                }

                Section {
                    Button(role: .destructive) { showLogoutConfirm = true } label: {
                        Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("我的")
            .confirmationDialog("确定要退出登录吗?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("退出", role: .destructive) { authService.logout() }
            } message: {
                Text("退出后需要重新认证才能使用应用")
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private func getAlbumCount() -> Int {
        (try? StorageService.shared.loadAlbums().count) ?? 0
    }

    private func getTotalPhotoCount() -> Int {
        guard let albums = try? StorageService.shared.loadAlbums() else { return 0 }
        return albums.reduce(0) { count, album in
            let photos = (try? StorageService.shared.loadPhotos(for: album.id)) ?? []
            return count + photos.count
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 14) {
                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 72))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.appPrimary)

                    Text("AI Photo Classifier")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("版本 1.0.0")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section("功能特点") {
                Label("AI 自动分类图片", systemImage: "sparkles")
                Label("Face ID 安全认证", systemImage: "faceid")
                Label("收藏夹密码保护", systemImage: "lock.fill")
                Label("图片加密存储", systemImage: "shield.fill")
                Label("AI 智能对话", systemImage: "message.fill")
            }

            Section("技术支持") {
                LabeledContent("AI 模型", value: "Claude Haiku 4.5")
                LabeledContent("加密算法", value: "AES-256-GCM")
                LabeledContent("API 代理", value: "aicanapi.com")
            }
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}
