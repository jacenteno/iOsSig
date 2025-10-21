import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var settings: SettingsManager
    
    let version: String
    let requestCode: String
    
    // MARK: - Animation States
    @State private var scaleAnimation: CGFloat = 1.0
    @State private var rotateAnimation: Double = 0.0
    @State private var backgroundColorFraction: Double = 0.0
    @State private var particleOffset: Double = 0.0
    
    // MARK: - Image Carousel States
    @State private var currentImageIndex: Int = 0
    @State private var imageAlpha: Double = 1.0
    private let imageResources: [String] = ["ads1", "ads4", "ads6", "ads2", "ads3"]
    private let imageSwitchInterval: TimeInterval = 3.0
    private let fadeDuration: TimeInterval = 0.5
    
    var body: some View {
        ZStack {
            backgroundLayer
            logoLayer
            imageCarousel
            infoOverlay
        }
        .onAppear(perform: startAnimations)
    }
    
    // MARK: - View Components
    
    private var backgroundLayer: some View {
        interpolatedBackgroundColor
            .ignoresSafeArea()
    }
    
    private var logoLayer: some View {
        Image("logocmpc")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(0.60)
            .offset(y: sin(particleOffset * .pi / 180) * 50)
            .rotationEffect(.degrees(rotateAnimation))
    }
    
    private var imageCarousel: some View {
        Image(imageResources[currentImageIndex])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .opacity(imageAlpha)
            .transition(.opacity)
    }
    
    private var infoOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                infoPanel
            }
        }
    }
    
    private var infoPanel: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("CITYMALL DAVID")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.red)
                .scaleEffect(scaleAnimation)
            
            infoText("Licencia: \(requestCode)", size: 8)
            infoText("Device: \(settings.userRole.rawValue)", size: 10)
            infoText("Version: \(version)", size: 10)
        }
        .padding(.trailing, 16)
        .padding(.bottom, 24)
    }
    
    // MARK: - Helper Views
    
    private func infoText(_ text: String, size: CGFloat) -> some View {
        Text(text)
            .font(.system(size: size, weight: .semibold))
            .foregroundColor(.red)
    }
    
    private var interpolatedBackgroundColor: Color {
        let startColor = Color(red: 0xFF / 255.0, green: 0xFA / 255.0, blue: 0xF6 / 255.0)
        let endColor = Color(red: 0xF8 / 255.0, green: 0xF4 / 255.0, blue: 0xF4 / 255.0)
        return lerp(start: startColor, end: endColor, fraction: backgroundColorFraction)
    }
    
    // MARK: - Animations Setup
    
    private func startAnimations() {
        startScaleAnimation()
        startRotateAnimation()
        startBackgroundAnimation()
        startParallaxAnimation()
        startImageCarousel()
    }
    
    private func startScaleAnimation() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            scaleAnimation = 1.1
        }
    }
    
    private func startRotateAnimation() {
        withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) {
            rotateAnimation = 360.0
        }
    }
    
    private func startBackgroundAnimation() {
        withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
            backgroundColorFraction = 1.0
        }
    }
    
    private func startParallaxAnimation() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            particleOffset = 360.0
        }
    }
    
    private func startImageCarousel() {
        Timer.scheduledTimer(withTimeInterval: imageSwitchInterval, repeats: true) { _ in
            fadeOutAndSwitchImage()
        }
    }
    
    private func fadeOutAndSwitchImage() {
        withAnimation(.easeInOut(duration: fadeDuration)) {
            imageAlpha = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) {
            currentImageIndex = (currentImageIndex + 1) % imageResources.count
            
            withAnimation(.easeInOut(duration: fadeDuration)) {
                imageAlpha = 1.0
            }
        }
    }
    
    // MARK: - Color Interpolation
    
    private func lerp(start: Color, end: Color, fraction: Double) -> Color {
        let startComps = start.components
        let endComps = end.components
        
        let red = startComps.red + (endComps.red - startComps.red) * fraction
        let green = startComps.green + (endComps.green - startComps.green) * fraction
        let blue = startComps.blue + (endComps.blue - startComps.blue) * fraction
        let opacity = startComps.opacity + (endComps.opacity - startComps.opacity) * fraction
        
        return Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - Extensions

extension Color {
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return (0, 0, 0, 1)
        }
        
        return (Double(r), Double(g), Double(b), Double(a))
    }
}

// MARK: - Preview

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(version: "1.0", requestCode: "ABC-123")
            .environmentObject(SettingsManager.shared)
    }
}
