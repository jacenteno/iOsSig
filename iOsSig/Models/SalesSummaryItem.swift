import Foundation

struct SalesSummaryItem: Decodable, Identifiable {
    let id = UUID() // Add id for Identifiable conformance
    let nombre: String
    let transacciones: Int
    let monto: Double

    enum CodingKeys: String, CodingKey {
        case nombre, transacciones, monto
    }
}
