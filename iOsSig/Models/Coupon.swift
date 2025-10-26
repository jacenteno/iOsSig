import Foundation

struct Coupon: Codable, Identifiable {
    let codigo: String
    let validoHasta: String
    let qrCode: String

    var id: String { // id is a computed property
        codigo
    }

    enum CodingKeys: String, CodingKey {
        case codigo
        case validoHasta = "valido_hasta"
        case qrCode = "qr_code"
    }
}
