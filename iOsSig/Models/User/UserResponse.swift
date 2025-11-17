import Foundation

struct UserResponse: Codable, Equatable {
  let employeeId: String
  let username: String
  let email: String
  let fullName: String?
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case employeeId = "employee_id"
    case username
    case email
    case fullName = "full_name"
    case createdAt = "created_at"
  }
}
