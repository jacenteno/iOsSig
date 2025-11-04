import SwiftUI

// MARK: - Action Grid Button
struct ActionGridButton: View {
    let icon: String
    let title: String
    var isSelected: Bool = false
    var color: Color = .accentColor
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ActionGridButtonLabel(
                icon: icon,
                title: title,
                isSelected: isSelected,
                color: color
            )
        }
    }
}

struct ActionGridButtonLabel: View {
    let icon: String
    let title: String
    var isSelected: Bool = false
    var color: Color = .accentColor
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isSelected ? .white : color)
            
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? color : color.opacity(0.1))
        )
    }
}
