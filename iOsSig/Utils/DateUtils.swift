import Foundation

func convertClarionDateToString(clarionDate: Int?) -> String {
    guard let clarionDate = clarionDate, clarionDate > 0 else {
        return "N/A"
    }

    var dateComponents = DateComponents()
    dateComponents.year = 1800
    dateComponents.month = 12
    dateComponents.day = 28
    dateComponents.timeZone = TimeZone(identifier: "UTC")

    let calendar = Calendar(identifier: .gregorian)
    guard let epochDate = calendar.date(from: dateComponents) else {
        return "N/A"
    }

    guard let finalDate = calendar.date(byAdding: .day, value: clarionDate - 1, to: epochDate) else {
        return "N/A"
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy"
    return formatter.string(from: finalDate)
}
