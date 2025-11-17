import Foundation

struct ChartableSalesByHour: Identifiable {
  let id = UUID()
  let hour: String
  let amount: Double
}
