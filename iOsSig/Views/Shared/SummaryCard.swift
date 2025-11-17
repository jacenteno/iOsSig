import SwiftUI

// MARK: - Value Format (shared enum)
enum SummaryValueFormat {
  case currency
  case number
}

// MARK: - Legacy Summary Card (for backward compatibility)
struct SummaryCard: View {
  let title: String
  let value: Double
  let icon: String
  let format: SummaryValueFormat
  let color: Color

  var formattedValue: String {
    switch format {
    case .currency:
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      formatter.maximumFractionDigits = 2
      return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    case .number:
      return String(format: "%.0f", value)
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .font(.title2)
          .foregroundColor(color)
        Spacer()
      }

      Text(title)
        .font(.headline)
        .foregroundColor(.secondary)

      Text(formattedValue)
        .font(.body)
        .fontWeight(.medium)
        .foregroundColor(.primary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
    .padding()
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
  }
}
