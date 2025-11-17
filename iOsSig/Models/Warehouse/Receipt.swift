import Foundation

// MARK: - Paginated Response
struct PaginatedReceiptResponse: Codable {
  let count: Int
  let next: String?
  let previous: String?
  let results: [Receipt]
}

// MARK: - Receipt
struct Receipt: Codable, Identifiable {
  let id: Int
  let request: Int
  let requestId: Int
  let receiver: Int?  // Assuming receiver ID, can be null
  let receiverName: String?
  let requesterName: String
  let receivedAt: String
  let notes: String
  let status: String
  let receiptItems: [ReceiptItem]
  let receptionSummary: ReceptionSummary

  enum CodingKeys: String, CodingKey {
    case id, request, receiver, notes, status
    case requestId = "request_id"
    case receiverName = "receiver_name"
    case requesterName = "requester_name"
    case receivedAt = "received_at"
    case receiptItems = "receipt_items"
    case receptionSummary = "reception_summary"
  }
}

// MARK: - ReceiptItem
struct ReceiptItem: Codable, Identifiable {
  let id: Int
  let receipt: Int
  let requestItem: Int
  let productName: String
  let quantityUnitsReceived: Double?
  let quantityBoxesReceived: Double?
  let notes: String

  enum CodingKeys: String, CodingKey {
    case id, receipt, notes
    case requestItem = "request_item"
    case productName = "product_name"
    case quantityUnitsReceived = "quantity_units_received"
    case quantityBoxesReceived = "quantity_boxes_received"
  }
}

// MARK: - ReceptionSummary
struct ReceptionSummary: Codable {
  let totalLines: Int
  let totalUnitsRequested: Double
  let totalBoxesRequested: Double
  let totalUnitsDispatched: Double
  let totalBoxesDispatched: Double
  let totalUnitsReceived: Double
  let totalBoxesReceived: Double

  enum CodingKeys: String, CodingKey {
    case totalLines = "total_lines"
    case totalUnitsRequested = "total_units_requested"
    case totalBoxesRequested = "total_boxes_requested"
    case totalUnitsDispatched = "total_units_dispatched"
    case totalBoxesDispatched = "total_boxes_dispatched"
    case totalUnitsReceived = "total_units_received"
    case totalBoxesReceived = "total_boxes_received"
  }
}
