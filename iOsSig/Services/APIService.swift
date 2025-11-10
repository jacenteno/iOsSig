import Foundation

// Define errores personalizados para las llamadas de red
enum APIError: Error, CustomStringConvertible, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case serverError(statusCode: Int, detail: String? = nil)
    case decodingError(Error)
    case clientNotFound
    case productNotFound
    case timeout

    var isNotFoundError: Bool {
        switch self {
        case .serverError(let statusCode, _):
            return statusCode == 404
        case .productNotFound, .clientNotFound:
            return true
        default:
            return false
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL especificada no es válida."
        case .requestFailed(let error):
            return "La solicitud de red falló: \(error.localizedDescription)"
        case .serverError(let statusCode, let detail):
            if let detail = detail, !detail.isEmpty {
                // Intenta decodificar el detalle si es un JSON string
                if let data = detail.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let message = json.values.first as? [String] {
                            return "Error del servidor (código: \(statusCode)): \(message.first ?? detail)"
                        }
                    } catch {
                        // Si no es un JSON, devuelve el detalle tal cual
                        return "Error del servidor (código: \(statusCode)): \(detail)"
                    }
                }
                return "Error del servidor (código: \(statusCode)): \(detail)"
            }
            return "Error del servidor con código: \(statusCode)"
        case .decodingError(let error):
            return "Error al decodificar la respuesta del servidor: \(error.localizedDescription)"
        case .clientNotFound:
            return "Cliente no existe en la base de datos."
        case .productNotFound:
            return "Producto no encontrado en la base de datos."
        case .timeout:
            return "La solicitud ha excedido el tiempo de espera."
        }
    }

    var description: String {
        return errorDescription ?? "Un error desconocido de la API ha ocurrido."
    }
}

// Equivalente a tu ApiService de Retrofit
class APIService {
    static let shared = APIService()

    // Usamos el SettingsManager para obtener la URL base dinámicamente
    private var settings: SettingsManager
    private let session: URLSession

    var productApiUrl: String {
        settings.productApiUrl
    }


    var baseUrl: String {
        var url = settings.productApiUrl
        if url.hasSuffix("/") {
            url.removeLast()
        }
        return url
    }

    init(settings: SettingsManager = .shared) {
        self.settings = settings
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        self.session = URLSession(configuration: configuration)
    }

    // Obtiene un producto por su código de barras o código de producto
    func getProductByCode(codigo: String) async throws -> Product {
        let baseUrl = settings.productApiUrl
        let encodedCodigo = codigo.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        guard let url = URL(string: "\(baseUrl)api/productos/por-codproducto/\(encodedCodigo)/") else {
            throw APIError.invalidURL
        }
        
        do {
            return try await performRequest(url: url, validStatusCodes: [200])
        } catch APIError.serverError(let statusCode, _) where statusCode == 404 {
            throw APIError.productNotFound
        } catch {
            throw error
        }
    }

    // Actualiza el precio de un producto
    func updateProductPrice(codigo: String, updateData: [String: Any]) async throws {
        let trimmedCodigo = codigo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let encodedCodigo = trimmedCodigo.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw APIError.invalidURL
        }
        let baseUrl = settings.productApiUrl
        guard let url = URL(string: "\(baseUrl)api/actualizar-precio/\(encodedCodigo)/") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONSerialization.data(withJSONObject: updateData)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // If we have an error, let's try to decode the error message from the server
            if let errorBody = String(data: data, encoding: .utf8) {
                print("--- SERVER ERROR RESPONSE ---")
                print(errorBody)
                print("---------------------------")
                // Create a more descriptive error
                let detailedError = APIError.serverError(statusCode: httpResponse.statusCode, detail: errorBody)
                throw detailedError
            } else {
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
        }
        // No se espera contenido en la respuesta, solo el código de éxito
    }

    func getProducts(page: Int) async throws -> PaginatedProductResponse {
        let baseUrl = settings.productApiUrl
        var components = URLComponents(string: "\(baseUrl)api/productos/")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            let paginatedResponse = try decoder.decode(PaginatedProductResponse.self, from: data)
            return paginatedResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func getProductsByDepartment(coddep: String, page: Int) async throws -> PaginatedProductResponse {
        let baseUrl = settings.productApiUrl
        var components = URLComponents(string: "\(baseUrl)api/productos/por-coddep/\(coddep)/")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            let paginatedResponse = try decoder.decode(PaginatedProductResponse.self, from: data)
            return paginatedResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func getProductsByDepartmentRaw(coddep: String, page: Int) async throws -> Data {
        let baseUrl = settings.productApiUrl
        var components = URLComponents(string: "\(baseUrl)api/productos/por-coddep/\(coddep)/")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        return data
    }

    // Aquí puedes añadir el resto de las llamadas API que necesites:
    // - getProducts(page: Int)
    // - getProductsByDepartment(coddep: String, page: Int)
    // - getSalesData()

    func getSalesData() async throws -> SalesResponse {
        let baseUrl = settings.citymallApiUrl // Assuming citymallApiUrl is the base for sales data
        guard let url = URL(string: "\(baseUrl)api/sales-data/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let salesResponse = try JSONDecoder().decode(SalesResponse.self, from: data)
            return salesResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func getOnlineSalesData() async throws -> SalesResponse {
        let baseUrl = settings.productApiUrl
        guard let url = URL(string: "\(baseUrl)api/venta-online/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("APIService: API Response Status Code: \(httpResponse.statusCode)")
            print("APIService: API Response Headers: \(httpResponse.allHeaderFields)")
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("APIService: Raw API Response Data for Online Sales: \(responseString)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let salesResponse = try JSONDecoder().decode(SalesResponse.self, from: data)
            return salesResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }


    func createArticulo(articulo: Articulo) async throws -> Articulo {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for product creation
        guard let url = URL(string: "\(baseUrl)api/creaproductos/") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase // Assuming API expects snake_case

        request.httpBody = try encoder.encode(articulo)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // Assuming API returns snake_case
            let createdArticulo = try decoder.decode(Articulo.self, from: data)
            return createdArticulo
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func searchProductsByReference(reference: String) async throws -> Referencia {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for product search
        var components = URLComponents(string: "\(baseUrl)api/productos/buscar-por-referencia/")
        components?.queryItems = [
            URLQueryItem(name: "codigobarra", value: reference)
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            // Assuming API returns snake_case, adjust if needed
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let referencia = try decoder.decode(Referencia.self, from: data)
            return referencia
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func getAllRoles() async throws -> [RoleDTO] {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for roles
        guard let url = URL(string: "\(baseUrl)api/warehouse/roles/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            let roles = try decoder.decode([RoleDTO].self, from: data)
            return roles
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func getRoleByName(name: String) async throws -> RoleDTO {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for roles
        guard let url = URL(string: "\(baseUrl)api/warehouse/roles/\(name)/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            let role = try decoder.decode(RoleDTO.self, from: data)
            return role
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func getDepartamentos() async throws -> DepartamentoResponse {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for departments
        guard let url = URL(string: "\(baseUrl)api/departamentos/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            let departamentoResponse = try decoder.decode(DepartamentoResponse.self, from: data)
            return departamentoResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func getVentasMensuales(codproducto: String) async throws -> Venta {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for sales
        var components = URLComponents(string: "\(baseUrl)api/ventas-mensuales/")
        components?.queryItems = [
            URLQueryItem(name: "codproducto", value: codproducto)
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        print("APIService: Calling URL: \(url.absoluteString)")

        let (data, response) = try await session.data(from: url)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("APIService: Raw sales response: \(responseString)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            let ventaResponse = try decoder.decode(VentaResponse.self, from: data)
            let trimmedCodProducto = ventaResponse.codproducto.trimmingCharacters(in: .whitespacesAndNewlines)
            return Venta(codproducto: trimmedCodProducto, detalle: ventaResponse.detalle, ventasMensuales: ventaResponse.ventas_mensuales, totalVendido: ventaResponse.total_vendido, totalMonto: ventaResponse.total_monto)
        } catch {
            print("APIService: Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }

    func fetchAllRequests(statuses: [String]? = nil, createdAfter: Date? = nil) async throws -> [RequestOrderResponse] {
        let baseUrl = settings.productApiUrl
        guard var components = URLComponents(string: "\(baseUrl)api/warehouse/requests/") else {
            throw APIError.invalidURL
        }

        var queryItems = [URLQueryItem]()

        // Add status query items
        if let statuses = statuses {
            for status in statuses {
                queryItems.append(URLQueryItem(name: "status", value: status))
            }
        }

        // Add date query item
        if let createdAfter = createdAfter {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let dateString = formatter.string(from: createdAfter)
            queryItems.append(URLQueryItem(name: "created_after", value: dateString))
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.serverError(statusCode: statusCode)
        }

        do {
            let decoder = JSONDecoder()
            // Assuming the response is a paginated one, but the old function returned just the results.
            // Let's adjust to decode the paginated response and return the results array.
            let paginatedResponse = try decoder.decode(PaginatedOrderResponse.self, from: data)
            return paginatedResponse.results
        } catch {
            throw APIError.decodingError(error)
        }
    }



    func fetchRequestOrderById(orderId: Int) async throws -> RequestOrderResponse {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for warehouse
        guard let url = URL(string: "\(baseUrl)api/warehouse/requests/\(orderId)/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let requestOrderResponse = try decoder.decode(RequestOrderResponse.self, from: data)
            return requestOrderResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func createRequestOrder(orderRequest: CreateOrderRequest) async throws -> RequestOrderResponse {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for warehouse
        guard let url = URL(string: "\(baseUrl)api/warehouse/requests/") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        request.httpBody = try encoder.encode(orderRequest)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            let requestOrderResponse = try decoder.decode(RequestOrderResponse.self, from: data)
            return requestOrderResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func fetchRequestOrders(employeeId: String) async throws -> PaginatedOrderResponse {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for warehouse
        var components = URLComponents(string: "\(baseUrl)api/warehouse/requests/")
        components?.queryItems = [
            URLQueryItem(name: "employee_id", value: employeeId)
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let paginatedOrderResponse = try decoder.decode(PaginatedOrderResponse.self, from: data)
            return paginatedOrderResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func getOperatorById(operatorId: Int) async throws -> Operator {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for warehouse
        
        // Fetch all operators from the list endpoint
        guard let url = URL(string: "\(baseUrl)api/warehouse/operators/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        // --- START OF INVESTIGATIVE LOGGING ---
        if let jsonString = String(data: data, encoding: .utf8) {
            print("--- RAW JSON RESPONSE for /api/warehouse/operators/ ---")
            print(jsonString)
            print("----------------------------------------------------")
        }
        // --- END OF INVESTIGATIVE LOGGING ---

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            if statusCode == 404 {
                print("APIService: The operator list endpoint (/api/warehouse/operators/) was not found.")
            }
            throw APIError.serverError(statusCode: statusCode)
        }

        do {
            let decoder = JSONDecoder()
            
            // Decode the paginated response object
            let paginatedResponse = try decoder.decode(PaginatedOperatorResponse.self, from: data)
            let allOperators = paginatedResponse.results
            
            // Find the operator with the matching employee ID
            if let operatorDetail = allOperators.first(where: { $0.employeeId == String(operatorId) }) {
                return operatorDetail
            } else {
                print("APIService: Operator with employee ID \(operatorId) not found in the list of operators.")
                throw APIError.clientNotFound
            }
        } catch {
            print("APIService: Failed to decode paginated operator response: \(error)")
            throw APIError.decodingError(error)
        }
    }

    func getProducto(codigo: String) async throws -> ProductoCreadoResponse {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for products
        guard let url = URL(string: "\(baseUrl)api/productos/por-codproducto/\(codigo)/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let productoCreadoResponse = try decoder.decode(ProductoCreadoResponse.self, from: data)
            return productoCreadoResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func createProducto(producto: ProductoParaCrear) async throws -> ProductoCreadoResponse {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for products
        guard let url = URL(string: "\(baseUrl)api/creaproductos/") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()

        request.httpBody = try encoder.encode(producto)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(statusCode: -1)
        }
        
        guard (200...201).contains(httpResponse.statusCode) else {
            if let errorBody = String(data: data, encoding: .utf8) {
                print("--- SERVER ERROR RESPONSE (createProducto) ---")
                print(errorBody)
                print("---------------------------------------------")
                throw APIError.serverError(statusCode: httpResponse.statusCode, detail: errorBody)
            } else {
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
        }

        if let responseString = String(data: data, encoding: .utf8) {
            print("APIService: Raw response from createProducto: \(responseString)")
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let productoCreadoResponse = try decoder.decode(ProductoCreadoResponse.self, from: data)
            return productoCreadoResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    private func performRequest<T: Decodable>(url: URL, validStatusCodes: [Int]) async throws -> T {
        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.serverError(statusCode: -1)
            }

            if !validStatusCodes.contains(httpResponse.statusCode) {
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.requestFailed(error)
        }
    }

    private func performRequest<T: Decodable>(request: URLRequest, validStatusCodes: [Int]) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.serverError(statusCode: -1)
            }

            if !validStatusCodes.contains(httpResponse.statusCode) {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("APIService Error Response: \(responseString)")
                }
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.requestFailed(error)
        }
    }

        func getCitymallProduct(barCode: String) async throws -> Resultado {

            let apiServiceCMD = APIServiceCMD(settings: settings, session: session)

            let codigoBarra = CodigoBarra(codigoBarra: barCode)

            let request = ConsultaCodigoBarraRequest(consultaCodigoBarra: codigoBarra)

            let response = try await apiServiceCMD.consultaCodigoBarra(requestBody: request)

            return response.resultado

        }

    

            /// Obtiene productos agotados de la API con paginación y búsqueda opcional.

    

            func getAgotadoProducts(page: Int, searchQuery: String? = nil) async throws -> PaginatedAgotadoProductResponse {

    

                let baseUrl = settings.productApiUrl // Asumiendo que esta es la base para productos

    

                var components = URLComponents(string: "\(baseUrl)api/productos-agotados/")

    

                

    

                // Añadir paginación

    

                var queryItems = [URLQueryItem(name: "page", value: String(page))]

    

                

    

                // Añadir búsqueda si existe

    

                if let searchQuery = searchQuery, !searchQuery.isEmpty {

    

                    queryItems.append(URLQueryItem(name: "search", value: searchQuery))

    

                }

    

                

    

                components?.queryItems = queryItems

    

        

    

                guard let url = components?.url else {

    

                    throw APIError.invalidURL

    

                }

    

        

    

                let (data, response) = try await session.data(from: url)

    

        

    

                guard let httpResponse = response as? HTTPURLResponse else {

    

                    throw APIError.serverError(statusCode: -1)

    

                }

    

                guard httpResponse.statusCode == 200 else {

    

                    throw APIError.serverError(statusCode: httpResponse.statusCode)

    

                }

    

        

    

                do {

    

                    let decoder = JSONDecoder()

    

                    let paginatedResponse = try decoder.decode(PaginatedAgotadoProductResponse.self, from: data)

    

                    return paginatedResponse

    

                } catch {

    

                    throw APIError.decodingError(error)

    

                }

    

            }

    func fetchReceipts(status: String, createdAfter: Date) async throws -> PaginatedReceiptResponse {
        let baseUrl = settings.productApiUrl
        guard var components = URLComponents(string: "\(baseUrl)api/warehouse/recibosmercancia/") else {
            throw APIError.invalidURL
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateString = formatter.string(from: createdAfter)

        components.queryItems = [
            URLQueryItem(name: "status", value: status),
            URLQueryItem(name: "created_after", value: dateString)
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.serverError(statusCode: statusCode)
        }

        do {
            return try JSONDecoder().decode(PaginatedReceiptResponse.self, from: data)
        } catch {
            print("--- DECODING ERROR in fetchReceipts ---")
            print(error)
            print("-------------------------------------")
            throw APIError.decodingError(error)
        }
    }

    func fetchUserRequests(employeeId: String, statuses: [String]) async throws -> PaginatedOrderResponse {
        let baseUrl = settings.productApiUrl
        guard var components = URLComponents(string: "\(baseUrl)api/warehouse/requests/") else {
            throw APIError.invalidURL
        }

        var queryItems = [URLQueryItem(name: "employee_id", value: employeeId)]
        for status in statuses {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.serverError(statusCode: statusCode)
        }

        do {
            return try JSONDecoder().decode(PaginatedOrderResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
