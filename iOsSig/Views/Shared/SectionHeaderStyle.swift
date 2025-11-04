import SwiftUI

struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.accentColor)
            .textCase(.none)
            .padding(.bottom, 8)
    }
}

extension Text {
    func sectionHeader() -> some View {
        self.modifier(SectionHeaderStyle())
    }
}