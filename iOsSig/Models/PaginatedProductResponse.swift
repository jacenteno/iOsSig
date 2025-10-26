import Foundation

struct PaginatedProductResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Product]

    enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case results
    }
}
