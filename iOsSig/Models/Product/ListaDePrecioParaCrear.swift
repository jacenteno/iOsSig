import Foundation

struct ListaDePrecioParaCrear: Codable {
    let codGrPrecio: Int?
    let codBodega: String?
    let precioDeVenta: Double
    let codComp: Int?

    enum CodingKeys: String, CodingKey {
        case codGrPrecio = "codgrprecio"
        case codBodega = "codbodega"
        case precioDeVenta = "preciodeventa"
        case codComp = "codcomp"
    }
}
