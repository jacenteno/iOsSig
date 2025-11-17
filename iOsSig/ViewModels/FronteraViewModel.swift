import Combine
import Foundation
import SwiftUI
import os.log

@MainActor
class FronteraViewModel: ObservableObject {
  @Published var searchQuery: String = ""
  @Published var resultado: Resultado? = nil
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  private let apiService: APIServiceCMF
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "FronteraViewModel")

  // Debounce search
  private var cancellables = Set<AnyCancellable>()

  init(apiService: APIServiceCMF = APIServiceCMF(session: .shared)) {
    self.apiService = apiService
    logger.info("✨ FronteraViewModel inicializado")
  }

  func consultarCodigo() {
    logger.info("🔍 consultarCodigo() llamado con código: '\(self.searchQuery)'")

    guard !searchQuery.isEmpty else {
      return  // No consultes si el query está vacío, el debounce ya lo maneja
    }

    isLoading = true
    errorMessage = nil
    resultado = nil  // Limpia el resultado anterior

    Task {
      do {
        logger.debug("📦 Creando request con código: \(self.searchQuery)")
        let codigoBarra = CodigoBarra(codigoBarra: searchQuery)
        let request = ConsultaCodigoBarraRequest(consultaCodigoBarra: codigoBarra)

        logger.info("🌐 Llamando al API...")
        let response = try await apiService.consultaCodigoBarra(requestBody: request)

        logger.info("✅ Response recibida del API")
        logger.debug("📊 Error code: \(response.resultado.errorcode)")

        if response.resultado.errorcode == 0 {
          self.resultado = response.resultado
          logger.info("🏷️ Producto encontrado: \(response.resultado.codigoproducto ?? "N/A")")
          self.searchQuery = ""  // Clear the search query
        } else {
          self.errorMessage = "Producto no encontrado o código inválido."
          logger.warning("⚠️ Producto no encontrado (errorcode: \(response.resultado.errorcode))")
        }

      } catch let error as APIError {
        logger.error("❌ APIError: \(String(describing: error))")
        self.errorMessage = "Error API: \(error.localizedDescription)"
        self.searchQuery = ""  // Clear search query after API error
      } catch {
        logger.error("❌ Error general: \(error.localizedDescription)")
        self.errorMessage = "Error: \(error.localizedDescription)"
        self.searchQuery = ""  // Clear search query after general error
      }

      logger.info("🏁 Finalizando consulta (isLoading = false)")
      isLoading = false
    }
  }

  func clear() {
    searchQuery = ""
    resultado = nil
    errorMessage = nil
    isLoading = false
  }
}
