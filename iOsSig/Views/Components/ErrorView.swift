import SwiftUI

struct ErrorView: View {
  @EnvironmentObject var settings: SettingsManager

  let errorMessage: String
  let retryAction: () -> Void
  @Binding var isShowingError: Bool
  var showSettings: Binding<Bool>?

  var body: some View {
    let accentColor = Color(hex: settings.accentColor) ?? .accentColor

    VStack(spacing: 24) {
      Spacer()

      // Icono
      Image(systemName: "wifi.exclamationmark")
        .font(.system(size: 60, weight: .light))
        .foregroundColor(accentColor)
        .padding()
        .background(accentColor.opacity(0.1))
        .clipShape(Circle())

      // Mensaje
      VStack(spacing: 8) {
        Text("Ocurrió un Error")
          .font(.system(size: 24, weight: .bold, design: .rounded))

        Text(errorMessage)
          .font(.system(size: 17, weight: .medium, design: .rounded))
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .padding(.horizontal)
      }

      Spacer()

      // Botones de acción
      VStack(spacing: 14) {
        Button(action: {
          isShowingError = false
          retryAction()
        }) {
          Text("Reintentar")
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(accentColor)
            .foregroundColor(.white)
            .cornerRadius(16)
        }

        if let showSettings = showSettings {
          Button(action: {
            isShowingError = false
            showSettings.wrappedValue = true
          }) {
            Text("Ir a Configuración")
              .fontWeight(.semibold)
              .frame(maxWidth: .infinity)
              .padding()
              .background(accentColor.opacity(0.15))
              .foregroundColor(accentColor)
              .cornerRadius(16)
          }
        }

        Button(action: {
          isShowingError = false
        }) {
          Text("Cerrar")
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
        }
        .padding(.top, 8)
      }
    }
    .padding(30)
  }
}

struct ErrorView_Previews: PreviewProvider {
  static var previews: some View {
    ErrorView(
      errorMessage: "No se pudo conectar al servidor. Revisa tu conexión o la URL de la API.",
      retryAction: {},
      isShowingError: .constant(true),
      showSettings: .constant(true)
    )
    .environmentObject(SettingsManager.shared)
  }
}
