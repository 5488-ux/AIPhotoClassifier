import SwiftUI
import PhotosUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var showCreateAlbum = false

    let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.albums.isEmpty {
                    emptyStateView
                } else {
                    albumGridView
                }

                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView("AI正在分析图片...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .navigationTitle("我的收藏夹")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showImagePicker = true }) {
                            Label("上传图片", systemImage: "photo.on.rectangle.angled")
                        }

                        Button(action: { showCreateAlbum = true }) {
                            Label("新建收藏夹", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
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
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("暂无收藏夹")
                .font(.title2)
                .foregroundColor(.gray)

            Text("上传图片,AI将自动创建分类")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button(action: { showImagePicker = true }) {
                Label("上传图片", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.appPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    private var albumGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(viewModel.albums) { album in
                    NavigationLink(destination: AlbumDetailView(album: album, onUpdate: viewModel.updateAlbum)) {
                        AlbumGridCell(album: album, viewModel: viewModel)
                    }
                }
            }
            .padding()
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
            // Cover Image
            ZStack {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.appPrimary.opacity(0.6), Color.appSecondary.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .aspectRatio(1, contentMode: .fit)

                if let coverPhotoID = album.coverPhotoID,
                   let photo = viewModel.getAlbumPhotos(album).first(where: { $0.id == coverPhotoID }),
                   let thumbnail = photo.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                } else {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }

                if album.isEncrypted {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            .cornerRadius(12)

            // Album Info
            VStack(alignment: .leading, spacing: 4) {
                Text(album.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text("\(viewModel.getAlbumPhotos(album).count) 张照片")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
