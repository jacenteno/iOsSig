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
    /// Renders the view into a UIImage asynchronously, ensuring the view is properly rendered before capture.
    @MainActor
    func renderAsImage(size: CGSize? = nil) async -> UIImage? {
        // 1. Create a hosting controller
        let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.all))

        // 2. Determine the target size for rendering
        let targetSize = size ?? controller.view.intrinsicContentSize
        
        // Ensure the size is valid
        guard targetSize.width > 0, targetSize.height > 0 else {
            print("Warning: Attempted to render a view with zero size.")
            return nil
        }
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        controller.view.backgroundColor = .clear

        // 3. Create a temporary window to host the view hierarchy
        let window = UIWindow(frame: controller.view.bounds)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        
        // Allow the system a moment to handle layout and rendering
        await Task.yield()

        // 4. Render the view's layer into a UIImage
        let renderer = UIGraphicsImageRenderer(size: controller.view.bounds.size)
        let image = renderer.image { ctx in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        
        // 5. Clean up the temporary window
        window.isHidden = true
        
        return image
    }
}
