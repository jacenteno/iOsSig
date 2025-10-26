import Foundation

struct CreateOrderRequest: Codable {
    let employeeId: String
    let status: String
    let priority: Int
    let items: [CreateOrderItem]

    enum CodingKeys: String, CodingKey {
        case employeeId = "employee_id"
        case status
        case priority
        case items
    }
}
