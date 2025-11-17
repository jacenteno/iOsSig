import Foundation

struct CreateOrderItem: Codable {
  let productId: Int
  let quantityUnits: Double
  let quantityBoxes: Double

  enum CodingKeys: String, CodingKey {
    case productId = "product_id"
    case quantityUnits = "quantity_units"
    case quantityBoxes = "quantity_boxes"
  }
}
