import Foundation

struct Resultado: Codable {
    let errorcode: Int
    let codigoproducto: String
    let nombreproducto: String
    let precioventa: Double
    let nombreprecio: String
    let codigoprecio: String
    let nombremoneda: String
    let simbolomoneda: String
    let ultimocosto: Double
    let referencia: String
    let preciossucursales: [PrecioSucursal]
    let existencias: Double
    let tasaiva: Double
    let imagenproducto: String
    let nombreimagen: String
    let estado: Bool
    let ventas: Ventas
    let compras: Compras
    let infoData: [InfoData]

    enum CodingKeys: String, CodingKey {
        case errorcode
        case codigoproducto
        case nombreproducto
        case precioventa
        case nombreprecio
        case codigoprecio
        case nombremoneda
        case simbolomoneda
        case ultimocosto
        case referencia
        case preciossucursales
        case existencias
        case tasaiva
        case imagenproducto
        case nombreimagen
        case estado
        case ventas
        case compras
        case infoData = "infodata"
    }
}
