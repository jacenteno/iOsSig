import Foundation

class APIServiceCliente {
    private var settings: SettingsManager

    init(settings: SettingsManager = .shared) {
        self.settings = settings
    }

    func getCliente(valor: String) async throws -> ClienteResponse {
        let baseUrl = settings.clientApiUrl
        var components = URLComponents(string: "\(baseUrl)api/clientespuntos/")
        components?.queryItems = [
            URLQueryItem(name: "valor", value: valor)
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 404 {
            throw APIError.clientNotFound
        } else if httpResponse.statusCode != 200 {
            throw APIError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let clienteResponse = try decoder.decode(ClienteResponse.self, from: data)
            return clienteResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func generateCoupon(promoId: Int, rutNumerico: String) async throws -> CouponResponse {
        let baseUrl = settings.clientApiUrl
        guard let url = URL(string: "\(baseUrl)api/coupon/\(promoId)/\(rutNumerico)/") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let couponResponse = try decoder.decode(CouponResponse.self, from: data)
            return couponResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
