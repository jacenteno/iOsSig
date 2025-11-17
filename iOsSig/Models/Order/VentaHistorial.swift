import Foundation

struct VentaHistorial: Codable {
  let anno: Int
  let mes: Int
  let ventas: Int
  let salidas: Int?
  let titulo: String
  let keyAnnoMes: String

  enum CodingKeys: String, CodingKey {
    case anno
    case mes
    case ventas
    case salidas
    case titulo
    case keyAnnoMes = "keyannomes"
  }
}
