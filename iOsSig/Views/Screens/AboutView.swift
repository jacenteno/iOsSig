import SwiftUI

struct AboutView: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme
  @EnvironmentObject var settings: SettingsManager

  private var appVersion: String {
    let version =
      Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    return "Versión \(version) (Build \(build))"
  }

  var body: some View {
    NavigationView {
      VStack(spacing: 20) {
        Spacer()

        // App Icon
        Image("sig")
          .resizable()
          .scaledToFit()
          .frame(width: 100, height: 100)
          .clipShape(RoundedRectangle(cornerRadius: 18))
          .shadow(radius: 5)
          .onAppear {
            // Apply color inversion based on the theme from settings
            if settings.appColorScheme == .dark {
              // The view will be in dark mode
            }
          }
          .if(colorScheme == .dark) { view in
            view.colorInvert()
          }

        // App Name
        Text("SigApp")
          .font(.largeTitle)
          .fontWeight(.bold)

        // Version
        Text(appVersion)
          .font(.headline)
          .foregroundColor(.secondary)

        // Copyright
        Text("© 2025 JCenteno. Todos los derechos reservados.")
          .font(.caption)
          .foregroundColor(.secondary)

        Spacer()
        Spacer()

        // Links
        VStack(alignment: .leading, spacing: 15) {
          Link(destination: URL(string: "https://jacenteno.github.io")!) {
            HStack {
              Image(systemName: "doc.text.fill")
              Text("Términos de Servicio")
            }
            .foregroundColor(Color(hex: settings.accentColor) ?? .accentColor)
          }
          Link(destination: URL(string: "https://jacenteno.github.io")!) {
            HStack {
              Image(systemName: "shield.lefthalf.filled")
              Text("Política de Privacidad")
            }
            .foregroundColor(Color(hex: settings.accentColor) ?? .accentColor)
          }
          Link(destination: URL(string: "https://jacenteno.github.io")!) {
            HStack {
              Image(systemName: "safari.fill")
              Text("Visita nuestro sitio web")
            }
            .foregroundColor(Color(hex: settings.accentColor) ?? .accentColor)
          }
        }
        .font(.headline)

        Spacer()
      }
      .padding()
      .navigationTitle("Acerca de")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Hecho") {
            dismiss()
          }
          .foregroundColor(Color(hex: settings.accentColor) ?? .accentColor)
        }
      }
    }
    .preferredColorScheme(colorScheme(for: settings.appColorScheme))
  }

  private func colorScheme(for scheme: SettingsManager.AppColorScheme) -> ColorScheme? {
    switch scheme {
    case .light:
      return .light
    case .dark:
      return .dark
    case .system:
      return nil
    }
  }
}

extension View {
  @ViewBuilder
  func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

#Preview {
  AboutView()
    .environmentObject(SettingsManager.shared)
}
