import Foundation

struct Productos: Codable, Identifiable {
    var id: String { codproducto }
    let codproducto: String
    let codigobarra: String
    let desproducto: String
    let codbodega: String
    let coddep: Int
    let codfamilia: String

    enum CodingKeys: String, CodingKey {
        case codproducto
        case codigobarra
        case desproducto
        case codbodega
        case coddep
        case codfamilia
    }
}
