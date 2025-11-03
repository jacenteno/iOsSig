
import Foundation

/// Modelo para un producto agotado, tal como lo devuelve el endpoint /api/productos-agotados/.
/// Es Identifiable para poder usarse en listas de SwiftUI.
struct AgotadoProduct: Codable, Identifiable {
    let id = UUID() // Requerido por Identifiable, no viene del API
    let codbodega: String
    let codproducto: String
    let desproducto: String
    let ultcosto: Double
    let existencias: Double // Debería ser 0.0 para productos agotados
    let codigobarra: String
    let diasvencimiento: Int // Días restantes para el vencimiento (0 si ya vencido o no aplica)
    let ventas_mes_anterior: Int // Ventas totales del mes anterior

    // Mapeo de claves JSON a propiedades de Swift (si son diferentes o tienen espacios)
    enum CodingKeys: String, CodingKey {
        case codbodega
        case codproducto
        case desproducto
        case ultcosto
        case existencias
        case codigobarra
        case diasvencimiento
        case ventas_mes_anterior
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decodificar y limpiar espacios
        codbodega = try container.decode(String.self, forKey: .codbodega).trimmingCharacters(in: .whitespacesAndNewlines)
        codproducto = try container.decode(String.self, forKey: .codproducto).trimmingCharacters(in: .whitespacesAndNewlines)
        desproducto = try container.decode(String.self, forKey: .desproducto)
        ultcosto = try container.decode(Double.self, forKey: .ultcosto)
        existencias = try container.decode(Double.self, forKey: .existencias)
        codigobarra = try container.decode(String.self, forKey: .codigobarra).trimmingCharacters(in: .whitespacesAndNewlines)
        diasvencimiento = try container.decode(Int.self, forKey: .diasvencimiento)
        ventas_mes_anterior = try container.decode(Int.self, forKey: .ventas_mes_anterior)
    }
}
