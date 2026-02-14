import SwiftUI
import PhotosUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var showCreateAlbum = false

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.albums.isEmpty {
                    emptyStateView
                } else {
                    albumGridView
                }

                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .navigationTitle("收藏夹")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { showImagePicker = true }) {
                            Label("上传图片", systemImage: "photo.badge.plus")
                        }
                        Button(action: { showCreateAlbum = true }) {
                            Label("新建收藏夹", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImages: $selectedImages, onComplete: uploadImages)
            }
            .sheet(isPresented: $showCreateAlbum) {
                CreateAlbumView { name, category in
                    viewModel.createAlbum(name: name, category: category)
                }
            }
            .alert("错误", isPresented: $viewModel.showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "未知错误")
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("暂无收藏夹", systemImage: "photo.on.rectangle.angled")
        } description: {
            Text("上传图片，AI 将自动创建分类")
        } actions: {
            Button(action: { showImagePicker = true }) {
                Text("上传图片")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(.appPrimary)
        }
    }

    private var albumGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.albums) { album in
                    NavigationLink(value: album) {
                        AlbumGridCell(album: album, viewModel: viewModel)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.deleteAlbum(album)
                        } label: {
                            Label("删除收藏夹", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
        .navigationDestination(for: Album.self) { album in
            AlbumDetailView(album: album, onUpdate: viewModel.updateAlbum)
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                Text("AI 正在分析图片...")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(28)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func uploadImages() {
        Task {
            await viewModel.uploadImages(selectedImages)
            selectedImages.removeAll()
        }
    }
}

struct AlbumGridCell: View {
    let album: Album
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.5), Color.appSecondary.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(1, contentMode: .fit)

                if let coverPhotoID = album.coverPhotoID,
                   let photo = viewModel.getAlbumPhotos(album).first(where: { $0.id == coverPhotoID }),
                   let thumbnail = photo.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.9))
                }

                if album.isEncrypted {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(.white)
                                .padding(5)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text(album.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("\(viewModel.getAlbumPhotos(album).count) 张照片")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 2)
        }
    }
}
