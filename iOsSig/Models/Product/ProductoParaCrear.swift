import Foundation

struct ProductoParaCrear: Codable {
  let detalle: String
  let codBodega: String?
  let codProducto: String
  let codFamilia: String?
  let codClase: Int?
  let ultCosto: Double?
  let existencias: Double
  let codigoBarra: String
  let costoFob: Double?
  let desProducto: String
  let referencia: String?
  let codDep: Int?
  let prodPesado: Int?
  let codCompania: Int?
  let listasDePrecio: [ListaDePrecioParaCrear]
  let gravadoexecto: String
  let preciodeventa: Double
  let prcimpuestoventa: Double
  let codgrprecio: Int

  enum CodingKeys: String, CodingKey {
    case detalle
    case codBodega = "codbodega"
    case codProducto = "codproducto"
    case codFamilia = "codfamilia"
    case codClase = "codclase"
    case ultCosto = "ultcosto"
    case existencias
    case codigoBarra = "codigobarra"
    case costoFob = "costofob"
    case desProducto = "desproducto"
    case referencia
    case codDep = "coddep"
    case prodPesado = "prodpesado"
    case codCompania = "codcompania"
    case listasDePrecio = "listas_de_precio"
    case gravadoexecto
    case preciodeventa
    case prcimpuestoventa
    case codgrprecio
  }
}
