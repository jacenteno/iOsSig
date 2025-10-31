import SwiftUI
import Combine

class CartManager: ObservableObject {
    @Published var items: [OrderItem] = []

    var itemCount: Int {
        items.count
    }

    func addItem(product: Product, unidades: Int, cajas: Int) {
        if let index = items.firstIndex(where: { $0.product.codproducto == product.codproducto }) {
            // If the item already exists, update its quantities
            items[index].unidades += unidades
            items[index].cajas += cajas
        } else {
            // Otherwise, add it as a new item
            let newItem = OrderItem(id: product.codproducto ?? "", product: product, unidades: unidades, cajas: cajas)
            items.append(newItem)
        }
    }

    func updateItem(productID: String, unidades: Int, cajas: Int) {
        if let index = items.firstIndex(where: { $0.id == productID }) {
            items[index].unidades = unidades
            items[index].cajas = cajas
        }
    }

    func removeItem(productID: String) {
        items.removeAll { $0.id == productID }
    }

    func clearCart() {
        items.removeAll()
    }
}