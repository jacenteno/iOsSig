import Combine
import Foundation
import SwiftUI

/// ViewModel para la funcionalidad de "Asistente Proactivo".
/// Gestiona la lógica de negocio para generar alertas de inventario inteligentes.
@MainActor
class ProactiveAssistantViewModel: ObservableObject {

  @Published var inventoryAlerts: [InventoryAlert] = []
  @Published var isLoading: Bool = false
  @Published var searchQuery: String = ""

  private let analyticsService: AnalyticsService
  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()

  init(analyticsService: AnalyticsService = AnalyticsService(), apiService: APIService = .shared) {
    self.analyticsService = analyticsService
    self.apiService = apiService

    // Lógica de "debounce" para la búsqueda
    $searchQuery
      .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
      .removeDuplicates()
      .sink { [weak self] _ in
        Task {
          await self?.generateAlerts(isNewSearch: true)
        }
      }
      .store(in: &cancellables)
  }

  /// Obtiene productos y genera alertas, con soporte para búsqueda y paginación.
  func generateAlerts(isNewSearch: Bool = false) async {
    // Si es una nueva búsqueda, resetea el estado
    if isNewSearch {
      // Aquí iría la lógica para resetear la paginación
    }

    isLoading = true
    // Si es una nueva búsqueda, limpia los resultados anteriores
    if isNewSearch {
      inventoryAlerts.removeAll()
    }

    do {
      let paginatedResponse = try await apiService.getAgotadoProducts(
        page: 1, searchQuery: searchQuery)
      let agotadoProducts = paginatedResponse.results

      var newAlerts: [InventoryAlert] = []
      for product in agotadoProducts {
        let alert = InventoryAlert(
          product: product.toProduct(), currentStock: 0,
          lastMonthSales: product.ventas_mes_anterior, type: .outOfStock)
        newAlerts.append(alert)
      }

      // Actualiza la lista en el hilo principal
      DispatchQueue.main.async {
        self.inventoryAlerts = newAlerts
        self.isLoading = false
      }

    } catch {
      print("Error fetching agotado products: \(error.localizedDescription)")
      DispatchQueue.main.async {
        self.isLoading = false
      }
    }
  }
}

// Extensión para convertir AgotadoProduct a Product (para compatibilidad con InventoryAlert)
extension AgotadoProduct {
  func toProduct() -> Product {
    return Product(
      codcompania: nil,
      codbodega: self.codbodega,
      coddep: nil,
      desproducto: self.desproducto,
      detalle: nil,
      codigobarra: self.codigobarra,
      codproducto: self.codproducto,
      codproveedor: nil,
      referencia: nil,
      nombre_departamento: nil,
      ultcosto: self.ultcosto,
      existencias: self.existencias,
      ubicacion: nil,
      ofertas: nil,
      ucosto: nil,
      costofob: nil,
      indexproductos: nil,
      costooriginal: nil,
      preciodeventa: nil,
      fvencimiento: nil,  // No tenemos fvencimiento en AgotadoProduct directamente
      ctacontable: nil,
      bloqueofacturacion: nil,
      gravadoexecto: nil,
      prcimpuestoventa: nil,
      nombre_lista_precio: nil,
      listas_de_precio: nil,
      series_asociadas: nil,
      codigo_consultado: nil,
      lista_referencia: nil
    )
  }
}
