import Foundation

struct InfoData: Codable {
    let codDep: Int
    let nombreDep: String
    let codBodega: String
    let nombreBodega: String
    let codCompania: String
    let nombreCompania: String
    let codFamilia: String
    let nombreFamilia: String
    let codClase: Int
    let nombreClase: String
    let costoFob: Double
    let productoPesado: Int

    enum CodingKeys: String, CodingKey {
        case codDep = "coddep"
        case nombreDep = "nombredep"
        case codBodega = "codbodega"
        case nombreBodega = "nombrebodega"
        case codCompania = "codcompania"
        case nombreCompania = "nombrecompania"
        case codFamilia = "codfamilia"
        case nombreFamilia = "nombrefamilia"
        case codClase = "codclase"
        case nombreClase = "nombreclase"
        case costoFob = "costofob"
        case productoPesado = "productopesado"
    }
}
