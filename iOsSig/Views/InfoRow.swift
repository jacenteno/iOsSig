import SwiftUI

import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text("\(label):")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(valueColor)
                .fontWeight(.bold)
        }
    }
}
