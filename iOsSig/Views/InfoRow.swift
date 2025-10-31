import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .secondary
    var icon: String? = nil

    var body: some View {
        HStack {
            if let icon = icon {
                Label(label, systemImage: icon)
            } else {
                Text(label)
            }
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
