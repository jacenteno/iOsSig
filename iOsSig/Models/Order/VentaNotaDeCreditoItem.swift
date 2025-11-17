import Foundation

struct VentaNotaDeCreditoItem: Decodable {
  let transacciones: Int
  let monto: Double
  let clientes: Int
}
