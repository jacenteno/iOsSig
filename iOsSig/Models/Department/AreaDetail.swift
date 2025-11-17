import Foundation

struct AreaDetail: Identifiable, Decodable {
  let id = UUID()
  let nombre: String
  let totalMonto: Double
  let totalTransacciones: Int
  let cajas: [String: CashRegisterDetail]

  enum CodingKeys: String, CodingKey {
    case nombre
    case totalMonto = "total_monto"
    case totalTransacciones = "total_transacciones"
    case cajas
  }
}
