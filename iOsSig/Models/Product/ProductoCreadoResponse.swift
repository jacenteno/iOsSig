import Foundation

struct ProductoCreadoResponse: Codable {
  let codcompania: String?
  let codbodega: String?
  let coddep: Int?
  let codproducto: String?
  let desproducto: String?
  let prcimpuestoventa: Double?
  let gravadoexecto: String?
  let fechaultmodifica: Int?
  let fechacreacion: Int?
  let indexproductos: Int?

  enum CodingKeys: String, CodingKey {
    case codcompania
    case codbodega
    case coddep
    case codproducto
    case desproducto
    case prcimpuestoventa
    case gravadoexecto
    case fechaultmodifica
    case fechacreacion
    case indexproductos
  }
}
