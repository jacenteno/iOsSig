import Foundation

struct CodigoBarra: Codable {
    let codigoBarra: String

    enum CodingKeys: String, CodingKey {
        case codigoBarra = "CodigoBarra"
    }
}
