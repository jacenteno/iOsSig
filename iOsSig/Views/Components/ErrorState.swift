import SwiftUI

struct ErrorState: View {
  @EnvironmentObject var settings: SettingsManager

  let message: String
  let onRetry: () -> Void

  var body: some View {
    let accentColor = Color(hex: settings.accentColor) ?? .accentColor

    VStack(spacing: 24) {
      Spacer()

      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 50, weight: .light))
        .foregroundColor(.red)
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(Circle())

      VStack(spacing: 8) {
        Text("Ocurrió un Error")
          .font(.system(size: 20, weight: .bold, design: .rounded))

        Text(message)
          .font(.system(size: 16, weight: .medium, design: .rounded))
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 40)
      }

      Button(action: onRetry) {
        Label("Reintentar", systemImage: "arrow.clockwise")
          .font(.headline)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .background(accentColor)
          .foregroundColor(.white)
          .clipShape(Capsule())
      }
      .padding(.top)

      Spacer()
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct ErrorState_Previews: PreviewProvider {
  static var previews: some View {
    ErrorState(
      message: "No se pudo conectar al servidor. Por favor, revisa tu conexión a internet.",
      onRetry: {}
    )
    .environmentObject(SettingsManager.shared)
  }
}
