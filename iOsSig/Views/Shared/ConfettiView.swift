import SwiftUI

struct ConfettiView: View {
    @State private var animate: Bool = false

    var body: some View {
        ZStack {
            ForEach(0..<30) { _ in
                Text(["🎉", "🎊", "🥳", "✨"].randomElement()!)
                    .font(.system(size: .random(in: 20...40)))
                    .offset(x: .random(in: -200...200), y: .random(in: -400...0))
                    .rotationEffect(.degrees(.random(in: 0...360)))
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: .random(in: 2...4))
                        .delay(.random(in: 0...0.5)),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}
