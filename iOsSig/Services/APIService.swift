
import Foundation

// Define errores personalizados para las llamadas de red
enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}

// Equivalente a tu ApiService de Retrofit
class APIService {
    // Usamos el SettingsManager para obtener la URL base dinámicamente
    private var settings: SettingsManager

    init(settings: SettingsManager = .shared) {
        self.settings = settings
    }

    // Obtiene un producto por su código de barras o código de producto
    func getProductByCode(codigo: String) async throws -> Product {
        let baseUrl = settings.productApiUrl
        guard let url = URL(string: "\(baseUrl)api/productos/por-codproducto/\(codigo)/") else {
            throw APIError.invalidURL
        }

        do {
                    let (data, response) = try await URLSession.shared.data(from: url)
            
                    if let httpResponse = response as? HTTPURLResponse {
                        print("APIService: API Response Status Code: \(httpResponse.statusCode)")
                        print("APIService: API Response Headers: \(httpResponse.allHeaderFields)")
                    }
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("APIService: Raw API Response Data: \(responseString)")
                    }
            
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
    func updateProductPrice(codigo: String, newPrice: Double) async throws {
        let baseUrl = settings.productApiUrl
        guard let url = URL(string: "\(baseUrl)api/actualizar-precio/\(codigo)/") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["preciodeventa": newPrice]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
            throw APIError.invalidResponse
        }
        // No se espera contenido en la respuesta, solo el código de éxito
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

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("APIService: API Response Status Code: \(httpResponse.statusCode)")
            print("APIService: API Response Headers: \(httpResponse.allHeaderFields)")
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("APIService: Raw API Response Data: \(responseString)")
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

    func getOnlineSalesData() async throws -> SalesResponse {
        let baseUrl = settings.productApiUrl
        guard let url = URL(string: "\(baseUrl)api/venta-online/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

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
}
