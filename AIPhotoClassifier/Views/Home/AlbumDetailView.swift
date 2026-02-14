import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    let onUpdate: (Album) -> Void

    @StateObject private var viewModel: AlbumViewModel
    @State private var showPasswordPrompt = false
    @State private var passwordInput = ""
    @State private var showSettings = false
    @State private var selectedPhoto: Photo?
    @State private var isSelectMode = false
    @State private var selectedPhotos: Set<UUID> = []
    @State private var showDeleteSelected = false

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
            if viewModel.isUnlocked && !viewModel.photos.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isSelectMode ? "完成" : "选择") {
                        withAnimation(.snappy) {
                            isSelectMode.toggle()
                            if !isSelectMode { selectedPhotos.removeAll() }
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showSettings = true } label: {
                    Image(systemName: "ellipsis.circle")
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
        VStack(spacing: 0) {
            if viewModel.photos.isEmpty {
                ContentUnavailableView {
                    Label("暂无照片", systemImage: "photo")
                } description: {
                    Text("从主页上传图片开始")
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(viewModel.photos) { photo in
                            photoCell(photo)
                        }
                    }
                }
            }

            if isSelectMode && !selectedPhotos.isEmpty {
                deleteBar
            }
        }
    }

    @ViewBuilder
    private func photoCell(_ photo: Photo) -> some View {
        if let thumbnail = photo.thumbnail {
            ZStack(alignment: .topTrailing) {
                Button {
                    if isSelectMode {
                        toggleSelection(photo)
                    } else {
                        selectedPhoto = photo
                    }
                } label: {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: (UIScreen.main.bounds.width - 4) / 3,
                            height: (UIScreen.main.bounds.width - 4) / 3
                        )
                        .clipped()
                        .overlay {
                            if isSelectMode && selectedPhotos.contains(photo.id) {
                                Color.appPrimary.opacity(0.25)
                            }
                        }
                }

                if isSelectMode {
                    Image(systemName: selectedPhotos.contains(photo.id) ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(selectedPhotos.contains(photo.id) ? Color.appPrimary : .white)
                        .shadow(radius: 2)
                        .padding(6)
                }
            }
            .contextMenu {
                Button(role: .destructive) {
                    viewModel.deletePhoto(photo)
                } label: {
                    Label("删除照片", systemImage: "trash")
                }
            }
        }
    }

    private var deleteBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Text("已选择 \(selectedPhotos.count) 张")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(role: .destructive) { showDeleteSelected = true } label: {
                    Label("删除", systemImage: "trash")
                        .font(.subheadline).fontWeight(.semibold)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.bar)
        }
        .confirmationDialog("确定删除选中的 \(selectedPhotos.count) 张照片？", isPresented: $showDeleteSelected, titleVisibility: .visible) {
            Button("删除 \(selectedPhotos.count) 张照片", role: .destructive) {
                deleteSelectedPhotos()
            }
        }
    }

    private var lockedView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
            Text("此收藏夹已加密")
                .font(.title3).fontWeight(.semibold)
            VStack(spacing: 14) {
                SecureField("请输入密码", text: $passwordInput)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 280)
                Button(action: unlock) {
                    Text("解锁").fontWeight(.semibold).frame(maxWidth: 280)
                }
                .buttonStyle(.borderedProminent)
                .tint(.appPrimary)
                .controlSize(.large)
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

    private func toggleSelection(_ photo: Photo) {
        if selectedPhotos.contains(photo.id) {
            selectedPhotos.remove(photo.id)
        } else {
            selectedPhotos.insert(photo.id)
        }
    }

    private func deleteSelectedPhotos() {
        for photoID in selectedPhotos {
            if let photo = viewModel.photos.first(where: { $0.id == photoID }) {
                viewModel.deletePhoto(photo)
            }
        }
        selectedPhotos.removeAll()
        isSelectMode = false
    }
}

struct PhotoDetailView: View {
    let photo: Photo
    @ObservedObject var viewModel: AlbumViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ProgressView()
                        .tint(.white)
                        .controlSize(.large)
                }
            }
            .navigationTitle("照片详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) { showDeleteConfirm = true } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .onAppear { image = viewModel.loadImage(for: photo) }
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

    var body: some View {
        NavigationStack {
            Form {
                Section("收藏夹信息") {
                    LabeledContent("名称", value: viewModel.album.name)
                    LabeledContent("分类", value: viewModel.album.category)
                    LabeledContent("照片数量", value: "\(viewModel.photos.count)")
                    LabeledContent("创建时间", value: viewModel.album.createdAt.formattedString())
                }
                Section("加密设置") {
                    if viewModel.album.isEncrypted {
                        Button("移除密码", role: .destructive) {
                            viewModel.removePassword()
                            onUpdate(viewModel.album)
                        }
                    } else {
                        Button("设置密码") { showSetPassword = true }
                    }
                }
            }
            .navigationTitle("收藏夹设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
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
        NavigationStack {
            Form {
                Section {
                    SecureField("输入密码", text: $password)
                    SecureField("确认密码", text: $confirmPassword)
                }
                Section {
                    Button("设置密码") { setPassword() }
                        .disabled(password.isEmpty || confirmPassword.isEmpty)
                }
            }
            .navigationTitle("设置密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
            .alert("密码不匹配", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            }
        }
    }

    private func setPassword() {
        guard password == confirmPassword else { showError = true; return }
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
        NavigationStack {
            Form {
                Section {
                    TextField("收藏夹名称", text: $name)
                    TextField("分类", text: $category)
                }
                Section {
                    Button("创建") { onCreate(name, category); dismiss() }
                        .disabled(name.isEmpty || category.isEmpty)
                }
            }
            .navigationTitle("新建收藏夹")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}
