import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    let onUpdate: (Album) -> Void

    @StateObject private var viewModel: AlbumViewModel
    @State private var showPasswordPrompt = false
    @State private var passwordInput = ""
    @State private var showSettings = false
    @State private var selectedPhoto: Photo?

    init(album: Album, onUpdate: @escaping (Album) -> Void) {
        self.album = album
        self.onUpdate = onUpdate
        _viewModel = StateObject(wrappedValue: AlbumViewModel(album: album))
    }

    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        Group {
            if viewModel.isUnlocked {
                unlockedView
            } else {
                lockedView
            }
        }
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            AlbumSettingsView(viewModel: viewModel, onUpdate: onUpdate)
        }
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo, viewModel: viewModel)
        }
    }

    private var unlockedView: some View {
        ScrollView {
            if viewModel.photos.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("暂无照片")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(viewModel.photos) { photo in
                        if let thumbnail = photo.thumbnail {
                            Button(action: { selectedPhoto = photo }) {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: (UIScreen.main.bounds.width - 4) / 3,
                                           height: (UIScreen.main.bounds.width - 4) / 3)
                                    .clipped()
                            }
                        }
                    }
                }
            }
        }
    }

    private var lockedView: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("此收藏夹已加密")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 15) {
                SecureField("请输入密码", text: $passwordInput)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)

                Button(action: unlock) {
                    Text("解锁")
                        .font(.headline)
                        .frame(maxWidth: 300)
                        .padding()
                        .background(Color.appPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            Spacer()
        }
        .padding()
        .alert("密码错误", isPresented: $showPasswordPrompt) {
            Button("确定", role: .cancel) {}
        }
    }

    private func unlock() {
        if viewModel.unlockAlbum(password: passwordInput) {
            passwordInput = ""
        } else {
            showPasswordPrompt = true
            passwordInput = ""
        }
    }
}

struct PhotoDetailView: View {
    let photo: Photo
    @ObservedObject var viewModel: AlbumViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .navigationTitle("照片详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive, action: { showDeleteConfirm = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
        }
        .onAppear {
            image = viewModel.loadImage(for: photo)
        }
        .confirmationDialog("确定删除这张照片?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                viewModel.deletePhoto(photo)
                dismiss()
            }
        }
    }
}

struct AlbumSettingsView: View {
    @ObservedObject var viewModel: AlbumViewModel
    let onUpdate: (Album) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var showSetPassword = false
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    var body: some View {
        NavigationView {
            Form {
                Section("收藏夹信息") {
                    Text("名称: \(viewModel.album.name)")
                    Text("分类: \(viewModel.album.category)")
                    Text("照片数量: \(viewModel.photos.count)")
                    Text("创建时间: \(viewModel.album.createdAt.formattedString())")
                }

                Section("加密设置") {
                    if viewModel.album.isEncrypted {
                        Button("移除密码", role: .destructive) {
                            viewModel.removePassword()
                            onUpdate(viewModel.album)
                        }
                    } else {
                        Button("设置密码") {
                            showSetPassword = true
                        }
                    }
                }
            }
            .navigationTitle("收藏夹设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSetPassword) {
                SetPasswordView { password in
                    viewModel.setPassword(password)
                    onUpdate(viewModel.album)
                }
            }
        }
    }
}

struct SetPasswordView: View {
    let onPasswordSet: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    SecureField("输入密码", text: $password)
                    SecureField("确认密码", text: $confirmPassword)
                }

                Section {
                    Button("设置密码") {
                        setPassword()
                    }
                    .disabled(password.isEmpty || confirmPassword.isEmpty)
                }
            }
            .navigationTitle("设置密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .alert("密码不匹配", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            }
        }
    }

    private func setPassword() {
        guard password == confirmPassword else {
            showError = true
            return
        }

        onPasswordSet(password)
        dismiss()
    }
}

struct CreateAlbumView: View {
    let onCreate: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("收藏夹名称", text: $name)
                    TextField("分类", text: $category)
                }

                Section {
                    Button("创建") {
                        onCreate(name, category)
                        dismiss()
                    }
                    .disabled(name.isEmpty || category.isEmpty)
                }
            }
            .navigationTitle("新建收藏夹")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}
