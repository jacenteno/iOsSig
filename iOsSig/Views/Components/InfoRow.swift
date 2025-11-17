import SwiftUI

struct InfoRow: View {
  let label: String
  let value: String
  var valueTextColor: Color = .secondary
  var valueTextFont: Font = .subheadline
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
        .font(valueTextFont)
        .fontWeight(.medium)
        .foregroundColor(valueTextColor)
    }
    .font(.subheadline)  // This applies to the label, not the value
  }
}
