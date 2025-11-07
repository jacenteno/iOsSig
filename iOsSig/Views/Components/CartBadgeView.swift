
import SwiftUI

struct CartBadgeView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "cart.fill")
                .font(.title3)

            if cartManager.itemCount > 0 {
                Text("\(cartManager.itemCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 10)
                    .offset(x: 8, y: -5)
                    .scaleEffect(cartManager.itemCount > 0 ? 1.0 : 0.0)
                    .animation(.spring(), value: cartManager.itemCount)
            }
        }
    }
}

struct CartBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        CartBadgeView()
            .environmentObject(CartManager())
    }
}
