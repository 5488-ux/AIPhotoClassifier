import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var onComplete: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0 // 0 means unlimited
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard !results.isEmpty else { return }

            let dispatchGroup = DispatchGroup()
            var images: [UIImage] = []

            for result in results {
                dispatchGroup.enter()

                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    defer { dispatchGroup.leave() }

                    if let image = object as? UIImage {
                        images.append(image)
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.parent.selectedImages = images
                self.parent.onComplete()
            }
        }
    }
}
