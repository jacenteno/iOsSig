import Foundation

enum Ventas: Codable {
  case listaVentas([VentaHistorial])
  case mensaje(String)

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let lista = try? container.decode([VentaHistorial].self) {
      self = .listaVentas(lista)
      return
    }
    if let mensaje = try? container.decode(String.self) {
      self = .mensaje(mensaje)
      return
    }
    throw DecodingError.typeMismatch(
      Ventas.self,
      DecodingError.Context(
        codingPath: decoder.codingPath, debugDescription: "Wrong type for Ventas"))
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .listaVentas(let lista):
      try container.encode(lista)
    case .mensaje(let mensaje):
      try container.encode(mensaje)
    }
  }
}
