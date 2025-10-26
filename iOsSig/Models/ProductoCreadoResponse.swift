import Foundation

struct ProductoCreadoResponse: Codable {
    let indexproductos: Int?
    let codproducto: String?
    let desproducto: String?
    let gravadoexecto: String
    let preciodeventa: Double
    let codgrprecio: Int

    enum CodingKeys: String, CodingKey {
        case indexproductos
        case codproducto
        case desproducto = "descproducto"
        case gravadoexecto
        case preciodeventa
        case codgrprecio
    }
}
