import SwiftUI

struct SearchBarView: View {
  @Binding var text: String
  var prompt: String

  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.secondary)

      TextField(prompt, text: $text)
        .foregroundColor(.primary)
        .disableAutocorrection(true)

      if !text.isEmpty {
        Button(action: { self.text = "" }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.secondary)
        }
      }
    }
    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
    .background(Color(.systemGray6))
    .cornerRadius(10)
    .padding(.horizontal)
  }
}
