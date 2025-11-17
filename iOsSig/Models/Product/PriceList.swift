import Foundation

struct PriceList: Codable {
  let idlistadeprecio: Int
  let codgrprecio: Int
  let codbodega: String
  let preciodeventa: Double
  let descxcantidad: Double
  let descxcantidad2: Double
  let descxcantidad3: Double
  let preciodeventa2: Double
  let preciodeventa3: Double
  let cambiaprecioalfacturar: Int
  let codfamilia: String
  let codcomp: Int
  let localreg: Int
  let fechamod: Int
  let horamod: Int
  let precioventatemp: Double
  let fechatemp1: Int
  let fechatemp2: Int
  let referenciatemp: String
  let codproducto: String

  enum CodingKeys: String, CodingKey {
    case idlistadeprecio
    case codgrprecio
    case codbodega
    case preciodeventa
    case descxcantidad
    case descxcantidad2
    case descxcantidad3
    case preciodeventa2
    case preciodeventa3
    case cambiaprecioalfacturar
    case codfamilia
    case codcomp
    case localreg
    case fechamod
    case horamod
    case precioventatemp
    case fechatemp1
    case fechatemp2
    case referenciatemp
    case codproducto
  }
}
