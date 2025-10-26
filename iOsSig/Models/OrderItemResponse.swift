import Foundation

struct OrderItemResponse: Codable {
    let product: ProductDetailResponse
    let quantityUnits: Double
    let quantityBoxes: Double
    let quantityUnitsDispatched: Double
    let quantityBoxesDispatched: Double

    enum CodingKeys: String, CodingKey {
        case product
        case quantityUnits = "quantity_units"
        case quantityBoxes = "quantity_boxes"
        case quantityUnitsDispatched = "quantity_units_dispatched"
        case quantityBoxesDispatched = "quantity_boxes_dispatched"
    }
}
