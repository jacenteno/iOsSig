import Foundation
import Combine
import SwiftUI
import os.log

@MainActor
class FronteraViewModel: ObservableObject {
    @Published var codigo: String = ""
    @Published var responseText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiService: APIServiceCMF
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "FronteraViewModel")

    init(apiService: APIServiceCMF = APIServiceCMF(session: .shared)) {
        self.apiService = apiService
        logger.info("✨ FronteraViewModel inicializado")
    }

    func consultarCodigo() {
        logger.info("🔍 consultarCodigo() llamado con código: '\(self.codigo)'")
        
        guard !codigo.isEmpty else {
            logger.warning("⚠️ Código vacío")
            errorMessage = "Por favor, ingrese un código."
            return
        }

        logger.info("⏳ Iniciando consulta...")
        isLoading = true
        errorMessage = nil
        responseText = ""

        Task {
            do {
                logger.debug("📦 Creando request con código: \(self.codigo)")
                let codigoBarra = CodigoBarra(codigoBarra: codigo)
                let request = ConsultaCodigoBarraRequest(consultaCodigoBarra: codigoBarra)
                
                logger.info("🌐 Llamando al API...")
                let response = try await apiService.consultaCodigoBarra(requestBody: request)
                
                logger.info("✅ Response recibida del API")
                logger.debug("📊 Error code: \(response.resultado.errorcode)")
                
                if let codigoProd = response.resultado.codigoproducto {
                    logger.info("🏷️ Producto encontrado: \(codigoProd)")
                }
                
                if let nombreProd = response.resultado.nombreproducto {
                    logger.info("📝 Nombre producto: \(nombreProd)")
                }
                
                let responseData = try JSONEncoder().encode(response)
                if let jsonString = String(data: responseData, encoding: .utf8) {
                    logger.debug("📄 JSON response completo generado (\(jsonString.count) caracteres)")
                    print("Response JSON:\n\(jsonString)")
                    self.responseText = jsonString
                } else {
                    logger.error("❌ No se pudo convertir response a String")
                    self.responseText = "No se pudo decodificar la respuesta."
                }
                
                logger.info("✅ Consulta completada exitosamente")

            } catch let error as APIError {
                logger.error("❌ APIError: \(String(describing: error))")
                print("APIError detallado: \(error)")
                self.errorMessage = "Error API: \(error.localizedDescription)"
            } catch {
                logger.error("❌ Error general: \(error.localizedDescription)")
                print("Error completo: \(error)")
                self.errorMessage = "Error: \(error.localizedDescription)"
            }
            
            logger.info("🏁 Finalizando consulta (isLoading = false)")
            isLoading = false
        }
    }
}
