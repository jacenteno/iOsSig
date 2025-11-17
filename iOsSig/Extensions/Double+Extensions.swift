import Foundation

extension Double {
  func formatted(withDecimalPlaces places: Int) -> String {
    return String(format: "%.\(places)f", self)
  }
}
