import Foundation

struct SeriesAsociadas: Codable {
    let totalSeries: Int
    let series: [String]
    let tieneMultiplesSeries: Bool

    enum CodingKeys: String, CodingKey {
        case totalSeries = "total_series"
        case series
        case tieneMultiplesSeries = "tiene_multiples_series"
    }
}
