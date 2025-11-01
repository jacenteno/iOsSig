import Foundation
import os.log

// MARK: - ProductDetails Model

/// A structure to hold detailed information about a product.
/// - Properties:
///   - costo: The cost of the product.
///   - costoFob: The Free On Board (FOB) cost of the product.
///   - existencia: The current stock quantity of the product.
///   - comprasRealizadas: The total purchases made for the product.
///   - found: A boolean indicating whether the product details were successfully found.
struct ProductDetails {
    let costo: Double?
    let costoFob: Double?
    let existencia: Int?
    let comprasRealizadas: Double?
    let found: Bool
}

class APIServiceCMD {
    private var settings: SettingsManager
    private let session: URLSession
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "APIService")

    init(settings: SettingsManager = .shared, session: URLSession) {
        self.settings = settings
        self.session = session
    }

    func consultaCodigoBarra(requestBody: ConsultaCodigoBarraRequest) async throws -> CitymallResponse {
        logger.info("🚀 Iniciando consultaCodigoBarra")
        
        let baseUrl = settings.citymallApiUrl.trimmingCharacters(in: .whitespacesAndNewlines)
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
            throw APIError.serverError(statusCode: -1)
        }
        
        logger.info("📊 Status code: \(httpResponse.statusCode)")
        logger.debug("📋 Headers: \(httpResponse.allHeaderFields)")
        
        guard httpResponse.statusCode == 200 else {
            logger.error("❌ Status code inválido: \(httpResponse.statusCode)")
            throw APIError.serverError(statusCode: httpResponse.statusCode)
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
        
        let baseUrl = settings.citymallApiUrl.trimmingCharacters(in: .whitespacesAndNewlines)
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
            throw APIError.serverError(statusCode: -1)
        }
        
        logger.info("📊 Status code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            logger.error("❌ Status code inválido: \(httpResponse.statusCode)")
            throw APIError.serverError(statusCode: httpResponse.statusCode)
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

    /// Fetches detailed information for a product given its product code.
    /// - Parameter productCode: The unique identifier for the product.
    /// - Returns: A `ProductDetails` object containing the product's cost, FOB cost, existence, total quantity purchased, and a status indicating if the product was found.
    /// - Throws: `APIError` if there's an issue with the API call or decoding the response.
    /// - Note: `costoFob` is not directly available in the current API response and will be `nil`.
    ///   `comprasRealizadas` is calculated as the sum of `cEnt` from all `CompraHistorial` items if available.
    func getProductDetails(productCode: String) async throws -> ProductDetails {
        logger.info("🚀 Iniciando getProductDetails para código: \(productCode)")

        guard !productCode.isEmpty else {
            logger.warning("⚠️ Código de producto vacío")
            return ProductDetails(costo: nil, costoFob: nil, existencia: nil, comprasRealizadas: nil, found: false)
        }

        do {
            let codigoBarra = CodigoBarra(codigoBarra: productCode)
            let request = ConsultaCodigoBarraRequest(consultaCodigoBarra: codigoBarra)

            let response = try await consultaCodigoBarra(requestBody: request)

            if response.resultado.errorcode == 0 {
                logger.info("✅ Producto encontrado. Extrayendo detalles.")

                var totalComprasRealizadas: Double? = nil
                if let compras = response.resultado.compras {
                    switch compras {
                    case .listaCompras(let historial):
                        totalComprasRealizadas = Double(historial.reduce(0) { $0 + ($1.cEnt ?? 0) })
                    case .mensaje(_):
                        totalComprasRealizadas = nil // No purchase history available
                    }
                }

                return ProductDetails(
                    costo: response.resultado.ultimocosto,
                    costoFob: nil, // Not found in Resultado.swift
                    existencia: response.resultado.existencias != nil ? Int(response.resultado.existencias!) : nil,
                    comprasRealizadas: totalComprasRealizadas,
                    found: true
                )
            } else {
                logger.info("ℹ️ Producto no encontrado o error en la respuesta (errorcode: \(response.resultado.errorcode))")
                return ProductDetails(costo: nil, costoFob: nil, existencia: nil, comprasRealizadas: nil, found: false)
            }
        } catch {
            logger.error("❌ Error al obtener detalles del producto: \(error.localizedDescription)")
            throw error
        }
    }
}