import Foundation

struct OrderItem: Identifiable {
  let id: String
  let product: Product
  var unidades: Int
  var cajas: Int
}
