import Foundation

struct VentaResponse: Codable {
    let codproducto: String
    let detalle: String
    let ventas_mensuales: [VentaMensual]
    let total_vendido: Float
    let total_monto: Float
}
