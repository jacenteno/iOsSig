import SwiftUI

struct Badge: View {
    let count: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            Text(String(count))
                .font(.system(size: 12))
                .padding(5)
                .background(Color.red)
                .clipShape(Circle())
                .foregroundColor(.white)
                // Offset the badge to overlap with the icon
                .offset(x: 10, y: -10)
        }
    }
}
