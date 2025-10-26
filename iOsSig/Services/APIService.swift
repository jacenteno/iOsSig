import Foundation

// Define errores personalizados para las llamadas de red
enum APIError: Error, CustomStringConvertible, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case clientNotFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL especificada no es válida."
        case .requestFailed(let error):
            return "La solicitud de red falló: \(error.localizedDescription)"
        case .invalidResponse:
            return "Se recibió una respuesta inválida del servidor."
        case .decodingError(let error):
            return "Error al decodificar la respuesta del servidor: \(error.localizedDescription)"
        case .clientNotFound:
            return "Cliente no existe en la base de datos."
        }
    }

    var description: String {
        return errorDescription ?? "Un error desconocido de la API ha ocurrido."
    }
}

// Equivalente a tu ApiService de Retrofit
class APIService {
    // Usamos el SettingsManager para obtener la URL base dinámicamente
    private var settings: SettingsManager
    private let session: URLSession

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
                    let (data, response) = try await session.data(from: url)
            
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        throw APIError.invalidResponse
                    }
                        do {
                let product = try JSONDecoder().decode(Product.self, from: data)
                return product
            } catch {
                throw APIError.decodingError(error)
            }
        } catch {
            throw APIError.requestFailed(error)
        }
    }

    // Actualiza el precio de un producto
    func updateProductPrice(codigo: String, updateData: [String: Any]) async throws {
        let baseUrl = settings.productApiUrl
        guard let url = URL(string: "\(baseUrl)api/actualizar-precio/\(codigo)/") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONSerialization.data(withJSONObject: updateData)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
            throw APIError.invalidResponse
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // Assuming API returns snake_case
            let venta = try decoder.decode(Venta.self, from: data)
            return venta
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func getRequestOrderById(orderId: Int) async throws -> RequestOrderResponse {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for warehouse
        guard let url = URL(string: "\(baseUrl)api/warehouse/requests/\(orderId)/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

    func getRequestOrders(employeeId: String) async throws -> PaginatedOrderResponse {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for warehouse
        var components = URLComponents(string: "\(baseUrl)api/warehouse/requests/")
        components?.queryItems = [
            URLQueryItem(name: "employee_id", value: employeeId)
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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
        guard let url = URL(string: "\(baseUrl)api/warehouse/operators/\(operatorId)/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let operatorResponse = try decoder.decode(Operator.self, from: data)
            return operatorResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func getProducto(codigo: String) async throws -> ProductoCreadoResponse {
        let baseUrl = settings.productApiUrl // Assuming productApiUrl is the base for products
        guard let url = URL(string: "\(baseUrl)api/productos/por-codproducto/\(codigo)/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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
        encoder.keyEncodingStrategy = .convertToSnakeCase

        request.httpBody = try encoder.encode(producto)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
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

    func getCitymallProduct(barCode: String) async throws -> Resultado {
        let apiServiceCMF = APIServiceCMF(settings: settings, session: session)
        let codigoBarra = CodigoBarra(codigoBarra: barCode)
        let request = ConsultaCodigoBarraRequest(consultaCodigoBarra: codigoBarra)
        let response = try await apiServiceCMF.consultaCodigoBarra(requestBody: request)
        return response.resultado
    }
}