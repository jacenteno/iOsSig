import Foundation

struct Referencia: Codable {
    let codigobarra: String
    let productos: [Productos]

    enum CodingKeys: String, CodingKey {
        case codigobarra
        case productos = "Producto_enlaces"
    }
}
