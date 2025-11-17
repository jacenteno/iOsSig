import Foundation

struct VentaMensual: Codable, Identifiable {
  var id: String { "\(anio)-\(mes)" }
  let mes: Int
  let anio: Int
  let totalUnidades: Float
  let totalMontos: Float  // This will be 0.0 if not present in JSON
  let fechaReal: String?  // Not present in the sales array from the log, so making it optional.

  enum CodingKeys: String, CodingKey {
    case mes
    case anio = "anno"  // Map 'anio' property to 'anno' key from JSON
    case totalUnidades = "ventas"  // Map 'totalUnidades' property to 'ventas' key from JSON
    case totalMontos = "total_montos"
    case fechaReal = "fecha_real"
  }

  // Custom initializer to handle potential missing values gracefully
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    mes = try container.decode(Int.self, forKey: .mes)
    anio = try container.decode(Int.self, forKey: .anio)
    totalUnidades = try container.decode(Float.self, forKey: .totalUnidades)

    // Attempt to decode optional values, providing defaults if they are missing
    totalMontos = (try? container.decode(Float.self, forKey: .totalMontos)) ?? 0.0
    fechaReal = (try? container.decode(String.self, forKey: .fechaReal))
  }
}
