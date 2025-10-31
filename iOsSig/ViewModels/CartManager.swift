
import SwiftUI
import Combine

class CartManager: ObservableObject {
    @Published var itemCount: Int = 0
    
    func addItem() {
        itemCount += 1
    }
    
    func clearCart() {
        itemCount = 0
    }
}
