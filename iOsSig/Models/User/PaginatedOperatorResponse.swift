import Foundation

struct PaginatedOperatorResponse: Codable {
  let count: Int
  let next: String?
  let previous: String?
  let results: [Operator]
}
