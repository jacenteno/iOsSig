import Foundation

struct PaginatedOrderResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [RequestOrderResponse]

    enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case results
    }
}
