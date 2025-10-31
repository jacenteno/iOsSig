import SwiftUI

import SwiftUI

struct EmptyStateView: View {
    var systemImage: String = "magnifyingglass"
    var message: String = "No se encontraron resultados."
    var retryAction: (() -> Void)? = nil
    var retryButtonText: String = "Reintentar"

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if let retryAction = retryAction {
                Button(retryButtonText, action: retryAction)
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
            }
            
            Spacer()
        }
    }
}
