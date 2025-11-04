import Foundation

struct CashRegisterDetail: Identifiable, Decodable {
    let id = UUID()
    let nombre: String
    let transacciones: Int
    let monto: Double

    enum CodingKeys: String, CodingKey {
        case nombre, transacciones, monto
    }
}
