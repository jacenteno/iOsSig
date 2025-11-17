import Foundation

/// Representa una alerta de inventario para un producto específico.
/// Es identificable para poder usarse en listas de SwiftUI.
struct InventoryAlert: Identifiable {
  enum AlertType { case lowStock, outOfStock }

  let id = UUID()
  let product: Product
  let currentStock: Double
  let lastMonthSales: Int
  let type: AlertType
}
