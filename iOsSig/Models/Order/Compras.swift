import Foundation

enum Compras: Codable {
    case listaCompras([CompraHistorial])
    case mensaje(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let lista = try? container.decode([CompraHistorial].self) {
            self = .listaCompras(lista)
            return
        }
        if let mensaje = try? container.decode(String.self) {
            self = .mensaje(mensaje)
            return
        }
        throw DecodingError.typeMismatch(Compras.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Compras can be either [CompraHistorial] or String"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .listaCompras(let lista):
            try container.encode(lista)
        case .mensaje(let mensaje):
            try container.encode(mensaje)
        }
    }
}
