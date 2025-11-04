import Foundation

struct Promotion: Codable {
    let id: Int
    let name: String
    let discountPercentage: String?
    let discountAmount: Float?
    let discountType: String
    let discountValue: Float
    let isActive: Bool
    let isCurrentlyActive: Bool
    let startDate: String?
    let endDate: String?
    let dailyStartTime: String?
    let dailyEndTime: String?
    let specificDate: String?
    let specificStartTime: String?
    let specificEndTime: String?
    let minPurchaseAmount: Float?
    let minQuantity: Int?
    let isLoyaltyOnly: Bool
    let schedules: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case discountPercentage = "discount_percentage"
        case discountAmount = "discount_amount"
        case discountType = "discount_type"
        case discountValue = "discount_value"
        case isActive = "is_active"
        case isCurrentlyActive = "is_currently_active"
        case startDate = "start_date"
        case endDate = "end_date"
        case dailyStartTime = "daily_start_time"
        case dailyEndTime = "daily_end_time"
        case specificDate = "specific_date"
        case specificStartTime = "specific_start_time"
        case specificEndTime = "specific_end_time"
        case minPurchaseAmount = "min_purchase_amount"
        case minQuantity = "min_quantity"
        case isLoyaltyOnly = "is_loyalty_only"
        case schedules
    }
}
