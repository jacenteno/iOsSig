import SwiftUI

import SwiftUI

struct ErrorState: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Error al Cargar Datos")
                .font(.headline)
                .fontWeight(.bold)
            Text(message)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Reintentar") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.top)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
