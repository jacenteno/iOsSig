
import Foundation

/// Modelo para la respuesta paginada del endpoint /api/productos-agotados/.
struct PaginatedAgotadoProductResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [AgotadoProduct]
}
