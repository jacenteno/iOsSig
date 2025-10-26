import Foundation

struct CompraHistorial: Codable {
    let numdoc: String
    let tipo: String
    let costou: Double
    let costop: Double
    let cEnt: Int
    let cSal: Int
    let fecmov: String
    let prov: String

    enum CodingKeys: String, CodingKey {
        case numdoc
        case tipo
        case costou
        case costop
        case cEnt = "c_ent"
        case cSal = "c_sal"
        case fecmov
        case prov
    }
}
