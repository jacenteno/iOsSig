import SwiftUI

import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject var settings: SettingsManager
    
    var systemImage: String = "magnifyingglass"
    var message: String = "No se encontraron resultados."
    var retryAction: (() -> Void)? = nil
    var retryButtonText: String = "Reintentar"

    var body: some View {
        let accentColor = Color(hex: settings.accentColor) ?? .accentColor

        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: systemImage)
                .font(.system(size: 50, weight: .light))
                .foregroundColor(accentColor)
                .padding()
                .background(accentColor.opacity(0.1))
                .clipShape(Circle())

            Text(message)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Label(retryButtonText, systemImage: "arrow.clockwise")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.top)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(
            message: "No hay productos en esta categoría.",
            retryAction: {}
        )
        .environmentObject(SettingsManager.shared)
    }
}

