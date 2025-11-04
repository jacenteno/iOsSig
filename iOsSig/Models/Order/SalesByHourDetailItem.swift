import Foundation

struct SalesByHourDetailItem: Decodable {
    let transacciones: Int
    let monto: Double
    let clientes: Int?
}