import Foundation

struct Venta: Codable {
    let codproducto: String
    let detalle: String
    let ventasMensuales: [VentaMensual]
    let totalVendido: Float
    let totalMonto: Float

    enum CodingKeys: String, CodingKey {
        case codproducto
        case detalle
        case ventasMensuales = "ventas_mensuales"
        case totalVendido = "total_vendido"
        case totalMonto = "total_monto"
    }
}
