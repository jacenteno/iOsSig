
import SwiftUI

struct ErrorView: View {
    let errorMessage: String
    let retryAction: () -> Void
    @Binding var isShowingError: Bool
    var showSettings: Binding<Bool>?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("Error de Conexión")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(errorMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            Button(action: {
                isShowingError = false
                retryAction()
            }) {
                Text("Reintentar")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            if let showSettings = showSettings {
                Button(action: {
                    isShowingError = false
                    showSettings.wrappedValue = true
                }) {
                    Text("Configuración")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                }
            }
            
            Button(action: {
                isShowingError = false
            }) {
                Text("Cerrar")
                    .fontWeight(.semibold)
            }
            .padding(.top)
        }
        .padding(30)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding()
    }
}