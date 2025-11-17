import Combine
import Foundation

@MainActor
class CambioPrecioViewModel: ObservableObject {
  @Published var product: Product?
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var newPriceString: String = ""
  @Published var showAlert = false
  @Published var alertMessage = ""

  private let apiService = APIService()
  private var settings: SettingsManager

  init(settings: SettingsManager = .shared) {
    self.settings = settings
  }

  func fetchProduct(codigo: String) async {
    isLoading = true
    errorMessage = nil
    do {
      product = try await apiService.getProductByCode(codigo: codigo)
    } catch {
      errorMessage = "Error al cargar el producto: \(error.localizedDescription)"
    }
    isLoading = false
  }

  func updatePrice(codigo: String) async {
    let trimmedCodigo = codigo.trimmingCharacters(in: .whitespacesAndNewlines)
    print("Iniciando cambio de precio para el código: \(trimmedCodigo)")
    guard let product = product else {
      print("Error: Producto no cargado.")
      return
    }

    print("Nuevo precio ingresado (string): '\(newPriceString)'")
    guard let newPrice = Double(newPriceString) else {
      alertMessage = "El precio debe ser un número válido."
      showAlert = true
      print("Error: El nuevo precio no es un número válido.")
      return
    }
    print("Nuevo precio (double): \(newPrice)")

    if let currentPrice = product.preciodeventa, newPrice == currentPrice {
      alertMessage = "El nuevo precio no puede ser igual al precio actual."
      showAlert = true
      print("Error: El nuevo precio es igual al actual.")
      return
    }

    // Temporary price check logic
    if let priceList = product.listas_de_precio?.first {
      let isTemporaryActive = isTemporaryPriceActive(
        fechapreciotemp1: priceList.fechatemp1, fechapreciotemp2: priceList.fechatemp2)
      print("Revisando precio temporal. Activo: \(isTemporaryActive)")
      if isTemporaryActive {
        alertMessage =
          "Este producto tiene un precio temporal activo y no se permite cambiar el precio."
        showAlert = true
        print("Error: Precio temporal activo.")
        return
      }
    }

    isLoading = true
    do {
      let updateData: [String: Any] = [
        "codcompania": settings.companyCode,
        "codbodega": settings.warehouseCode,
        "preciodeventa": newPrice,
      ]
      print("Enviando datos para actualizar: \(updateData)")
      try await apiService.updateProductPrice(codigo: trimmedCodigo, updateData: updateData)
      let oldPriceString = String(format: "%.2f", product.preciodeventa ?? 0.0)
      let newPriceStringFormatted = String(format: "%.2f", newPrice)
      alertMessage = "Precio actualizado de $\(oldPriceString) a $\(newPriceStringFormatted)."
      showAlert = true
      print("Éxito: Precio actualizado en el servidor.")
    } catch {
      alertMessage = "Error al actualizar el precio: \(error.localizedDescription)"
      showAlert = true
      print("Error en la llamada API para actualizar precio: \(error)")
    }
    isLoading = false
  }

  private func isTemporaryPriceActive(fechapreciotemp1: Int, fechapreciotemp2: Int) -> Bool {
    guard fechapreciotemp1 > 0, fechapreciotemp2 > 0 else { return false }

    let currentDate = Date()
    let startDate = convertClarionDate(clarionDate: fechapreciotemp1)
    let endDate = convertClarionDate(clarionDate: fechapreciotemp2)

    return currentDate >= startDate && currentDate <= endDate
  }

  private func convertClarionDate(clarionDate: Int) -> Date {
    var epoch = Calendar.current.date(
      from: DateComponents(year: 1800, month: 12, day: 28, hour: 0, minute: 0, second: 0))!
    return Calendar.current.date(byAdding: .day, value: clarionDate, to: epoch)!
  }
}
