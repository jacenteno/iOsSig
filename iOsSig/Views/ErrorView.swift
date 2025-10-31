import SwiftUI

struct ErrorView: View {
    let errorMessage: String
    let retryAction: () -> Void
    @Binding var isShowingError: Bool // New binding to control visibility
    @State private var countdown: Int = 5 // Initial countdown in seconds

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
                isShowingError = false // Dismiss immediately on manual retry
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
        }
        .padding(30)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding()
        .onAppear(perform: setupDismissTimer)
    }

    private func setupDismissTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                isShowingError = false // Dismiss the view
                retryAction() // Also trigger retry when dismissed
            }
        }
    }
}