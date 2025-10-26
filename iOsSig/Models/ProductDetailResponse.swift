import Foundation

struct ProductDetailResponse: Codable {
    let indexProductos: Int
    let codProducto: String
    let desProducto: String
    let ultCosto: Double
    let existencias: Double

    enum CodingKeys: String, CodingKey {
        case indexProductos = "indexproductos"
        case codProducto = "codproducto"
        case desProducto = "desproducto"
        case ultCosto = "ultcosto"
        case existencias
    }
}
