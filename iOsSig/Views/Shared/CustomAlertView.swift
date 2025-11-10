import SwiftUI

struct CustomAlertView: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        let accentColor = Color(hex: settings.accentColor) ?? .accentColor

        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Title and Message
                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(message)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Divider()
                
                // Buttons
                HStack(spacing: 0) {
                    Button(action: secondaryAction) {
                        Text(secondaryButtonTitle)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    
                    Divider()
                    
                    Button(action: primaryAction) {
                        Text(primaryButtonTitle)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(accentColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .frame(height: 50)
            }
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.2), radius: 10)
            .padding(.horizontal, 40)
        }
    }
}

struct CustomAlertView_Previews: PreviewProvider {
    static var previews: some View {
        CustomAlertView(
            title: "Producto no encontrado",
            message: "El producto con el código 12345 no existe. ¿Desea crearlo?",
            primaryButtonTitle: "Sí",
            secondaryButtonTitle: "No",
            primaryAction: { print("Sí tapped") },
            secondaryAction: { print("No tapped") }
        )
        .environmentObject(SettingsManager.shared)
    }
}
