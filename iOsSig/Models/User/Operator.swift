import Foundation

struct Operator: Codable {
  let id: Int
  let employeeId: String
  let username: String
  let email: String
  let fullName: String
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case employeeId = "employee_id"
    case username
    case email
    case fullName = "full_name"
    case createdAt = "created_at"
  }
}
