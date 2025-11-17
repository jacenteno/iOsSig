import Foundation

/// `AnalyticsService` se encarga de la lógica de negocio para analizar datos de inventario y ventas.
/// Se conecta al APIService real para obtener datos de ventas mensuales.
class AnalyticsService {

  private let apiService: APIService

  init(apiService: APIService = .shared) {
    self.apiService = apiService
  }
}
