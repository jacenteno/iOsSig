import SwiftUI

// MARK: - Custom UI Components

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isDisabled: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(placeholder)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .disabled(isDisabled)
                .keyboardType(keyboardType)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct CustomPicker<Content: View>: View {
    var title: String
    @Binding var selection: String
    var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker(title, selection: $selection, content: content)
                .pickerStyle(MenuPickerStyle())
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct CustomIntPicker<Content: View>: View {
    var title: String
    @Binding var selection: Int?
    var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker(title, selection: $selection, content: content)
                .pickerStyle(MenuPickerStyle())
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct CustomSectionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
