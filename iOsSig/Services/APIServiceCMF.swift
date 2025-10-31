import Foundation
import os.log

class APIServiceCMF {
    private var settings: SettingsManager
    private let session: URLSession
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "APIService")

    init(settings: SettingsManager = .shared, session: URLSession) {
        self.settings = settings
        self.session = session
    }

    func consultaCodigoBarra(requestBody: ConsultaCodigoBarraRequest) async throws -> CitymallResponse {
        logger.info("🚀 Iniciando consultaCodigoBarra")
        
        let baseUrl = settings.citymallFronteraApiUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        var finalUrlString = baseUrl
        if !finalUrlString.hasSuffix("/") {
            finalUrlString += "/"
        }
        finalUrlString += "consultaCodigoBarra"
        
        logger.info("📍 URL construida: \(finalUrlString)")

        guard let url = URL(string: finalUrlString) else {
            logger.error("❌ URL inválida: \(finalUrlString)")
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(requestBody)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        logger.debug("📤 Request body JSON: \(jsonString)")
        
        let postString = "json=\(jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = postString.data(using: .utf8)
        
        logger.debug("📦 POST string: \(postString)")
        logger.info("⏳ Enviando request...")

        let (data, response) = try await session.data(for: request)
        
        logger.info("✅ Response recibida")

        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("❌ Response no es HTTPURLResponse")
            throw APIError.invalidResponse
        }
        
        logger.info("📊 Status code: \(httpResponse.statusCode)")
        logger.debug("📋 Headers: \(httpResponse.allHeaderFields)")
        
        guard httpResponse.statusCode == 200 else {
            logger.error("❌ Status code inválido: \(httpResponse.statusCode)")
            throw APIError.invalidResponse
        }

        if data.isEmpty {
            logger.error("❌ Data vacía recibida")
            throw APIError.clientNotFound
        }
        
        logger.info("📦 Data recibida: \(data.count) bytes")
        
        if let responseString = String(data: data, encoding: .utf8) {
            logger.debug("📥 Response body: \(responseString)")
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let citymallResponse = try decoder.decode(CitymallResponse.self, from: data)
            logger.info("✅ Response decodificada exitosamente")
            logger.debug("🎯 Resultado errorcode: \(citymallResponse.resultado.errorcode)")
            return citymallResponse
        } catch {
            logger.error("❌ Error al decodificar: \(error.localizedDescription)")
            logger.error("🔍 Detalle del error: \(String(describing: error))")
            throw APIError.decodingError(error)
        }
    }

    func consultaCodigoBarraConBody(request: ConsultaCodigoBarraRequest) async throws -> CitymallResponse {
        logger.info("🚀 Iniciando consultaCodigoBarraConBody")
        
        let baseUrl = settings.citymallFronteraApiUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        var finalUrlString = baseUrl
        if !finalUrlString.hasSuffix("/") {
            finalUrlString += "/"
        }
        finalUrlString += "consultaCodigoBarra"
        
        logger.info("📍 URL construida: \(finalUrlString)")

        guard let url = URL(string: finalUrlString) else {
            logger.error("❌ URL inválida: \(finalUrlString)")
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let requestBody = try encoder.encode(request)
        urlRequest.httpBody = requestBody
        
        if let bodyString = String(data: requestBody, encoding: .utf8) {
            logger.debug("📤 Request body: \(bodyString)")
        }
        
        logger.info("⏳ Enviando request...")

        let (data, response) = try await session.data(for: urlRequest)
        
        logger.info("✅ Response recibida")

        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("❌ Response no es HTTPURLResponse")
            throw APIError.invalidResponse
        }
        
        logger.info("📊 Status code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            logger.error("❌ Status code inválido: \(httpResponse.statusCode)")
            throw APIError.invalidResponse
        }

        if data.isEmpty {
            logger.error("❌ Data vacía recibida")
            throw APIError.clientNotFound
        }
        
        logger.info("📦 Data recibida: \(data.count) bytes")
        
        if let responseString = String(data: data, encoding: .utf8) {
            logger.debug("📥 Response body: \(responseString)")
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let citymallResponse = try decoder.decode(CitymallResponse.self, from: data)
            logger.info("✅ Response decodificada exitosamente")
            return citymallResponse
        } catch {
            logger.error("❌ Error al decodificar: \(error.localizedDescription)")
            throw APIError.decodingError(error)
        }
    }
}
