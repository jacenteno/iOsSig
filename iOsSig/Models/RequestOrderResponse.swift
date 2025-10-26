import Foundation

struct RequestOrderResponse: Codable {
    let id: Int
    let user: UserResponse
    let createdAt: String
    let updatedAt: String
    let status: String
    let priority: Int
    let pdfReportUrl: String?
    let items: [OrderItemResponse]

    enum CodingKeys: String, CodingKey {
        case id
        case user
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case status
        case priority
        case pdfReportUrl = "pdf_report_url"
        case items
    }
}
