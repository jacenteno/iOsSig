import Foundation

struct VentaMensual: Codable, Identifiable {
    var id: String { "\(anio)-\(mes)" }
    let fechaReal: String
    let mes: Int
    let anio: Int
    let totalUnidades: Float
    let totalMontos: Float

    enum CodingKeys: String, CodingKey {
        case fechaReal = "fecha_real"
        case mes
        case anio
        case totalUnidades = "total_unidades"
        case totalMontos = "total_montos"
    }
}
