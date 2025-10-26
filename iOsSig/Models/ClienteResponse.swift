import Foundation

struct ClienteResponse: Codable {
    let cliente: Cliente
    let activePromotions: [Promotion]?

    enum CodingKeys: String, CodingKey {
        case cliente
        case activePromotions = "active_promotions"
    }
}
