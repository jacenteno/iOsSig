import Foundation

struct Articulo: Codable {
  let codcompania: Int
  let codbodega: String
  let coddep: Int?
  let codproducto: String
  let desproducto: String
  let prcimpuestoventa: Double
  let gravadoexecto: String
  let fechaultmodifica: Int
  let fechacreacion: Int
  let preciodeventa: Double
  let codgrprecio: Int
}
