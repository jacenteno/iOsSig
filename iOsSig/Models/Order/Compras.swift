import Foundation

enum Compras: Codable {
    case listaCompras([CompraHistorial])
    case mensaje(String)

 
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // 1. Si es nil → lista vacía
        if container.decodeNil() {
            self = .listaCompras([])
            return
        }

        // 2. NEW (and improved): Try to decode a dictionary containing a list, like {"compras": [...]}
        if let dict = try? container.decode([String: [CompraHistorial]].self),
           let firstList = dict.values.first {
            self = .listaCompras(firstList)
            return
        }

        // 3. Si es un array directo → lo tomamos
        if let lista = try? container.decode([CompraHistorial].self) {
            self = .listaCompras(lista)
            return
        }

        // 4. Si es un diccionario de items [String: CompraHistorial]
        if let dict = try? container.decode([String: CompraHistorial].self) {
            self = .listaCompras(Array(dict.values))
            return
        }

        // 5. Si es string → mensaje
        if let mensaje = try? container.decode(String.self) {
            self = .mensaje(mensaje)
            return
        }

        // 6. Cualquier otra cosa → lista vacía (no crashea)
        self = .listaCompras([])
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
