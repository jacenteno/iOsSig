import Foundation

struct CashRegisterSummaryItem: Decodable {
    let transacciones: Int
    let monto: Double
    let clientes: Int?
}