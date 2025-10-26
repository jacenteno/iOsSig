import Foundation

class APIServiceCMF {
    private var settings: SettingsManager
    private let session: URLSession

    init(settings: SettingsManager = .shared, session: URLSession) {
        self.settings = settings
        self.session = session
    }

    func consultaCodigoBarra(requestBody: ConsultaCodigoBarraRequest) async throws -> CitymallResponse {
        let baseUrl = settings.citymallFronteraApiUrl
        guard let url = URL(string: "\(baseUrl)consultaCodigoBarra") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase // Assuming API expects snake_case for the inner JSON

        let jsonString = String(data: try encoder.encode(requestBody), encoding: .utf8)!
        let postString = "json=\(jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = postString.data(using: .utf8)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // Assuming API returns snake_case
            let citymallResponse = try decoder.decode(CitymallResponse.self, from: data)
            return citymallResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func consultaCodigoBarraConBody(request: ConsultaCodigoBarraRequest) async throws -> CitymallResponse {
        let baseUrl = settings.citymallFronteraApiUrl
        guard let url = URL(string: "\(baseUrl)consultaCodigoBarra") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase // Assuming API expects snake_case

        urlRequest.httpBody = try encoder.encode(request)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // Assuming API returns snake_case
            let citymallResponse = try decoder.decode(CitymallResponse.self, from: data)
            return citymallResponse
        } catch {
            throw APIError.decodingError(error)
        }
    }
}