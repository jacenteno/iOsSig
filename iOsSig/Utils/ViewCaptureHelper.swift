
import SwiftUI

// MARK: - Share Sheet Helper
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - View Snapshot Extension
extension View {
    /// Renders the view into a UIImage.
    /// - Parameters:
    ///   - size: The target size for the rendered image. If nil, the view's ideal size is used.
    ///   - opaque: A Boolean value indicating whether the bitmap is opaque.
    ///   - scale: The scale factor to apply to the bitmap.
    /// - Returns: A UIImage of the rendered view.
    func asImage(size: CGSize? = nil, opaque: Bool = false, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        // 1. Create a UIHostingController to host the SwiftUI view.
        let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.all))
        
        // 2. Determine the target size.
        let targetSize = size ?? controller.view.intrinsicContentSize
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        controller.view.backgroundColor = .clear

        // 3. Create a renderer to capture the view.
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: .default())
        
        // 4. Render the view's layer into a UIImage.
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        
        return image
    }
}
