import SwiftUI

struct ProfileView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var showLogoutConfirm = false
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.appPrimary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("用户")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("已通过\(authService.getBiometryTypeString())认证")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }

                Section("数据统计") {
                    HStack {
                        Label("收藏夹数量", systemImage: "folder.fill")
                        Spacer()
                        Text("\(getAlbumCount())")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("总照片数", systemImage: "photo.fill")
                        Spacer()
                        Text("\(getTotalPhotoCount())")
                            .foregroundColor(.secondary)
                    }
                }

                Section("设置") {
                    Button(action: { showSettings = true }) {
                        Label("应用设置", systemImage: "gearshape")
                    }

                    NavigationLink(destination: AboutView()) {
                        Label("关于", systemImage: "info.circle")
                    }
                }

                Section {
                    Button(role: .destructive, action: { showLogoutConfirm = true }) {
                        Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("我的")
            .confirmationDialog("确定要退出登录吗?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("退出", role: .destructive) {
                    authService.logout()
                }
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
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "photo.stack.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.appPrimary)

                        Text("AI Photo Classifier")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("版本 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                }
            }

            Section("功能特点") {
                Label("AI自动分类图片", systemImage: "brain")
                Label("Face ID安全认证", systemImage: "faceid")
                Label("收藏夹密码保护", systemImage: "lock.fill")
                Label("图片加密存储", systemImage: "shield.fill")
                Label("AI智能对话", systemImage: "message.fill")
            }

            Section("技术支持") {
                HStack {
                    Text("AI模型")
                    Spacer()
                    Text("Claude Haiku 4.5")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("加密算法")
                    Spacer()
                    Text("AES-256-GCM")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}
