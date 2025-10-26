import Foundation
import Combine
//import HelperViews
import SwiftUI

class ClienteViewModel: ObservableObject {
    @Published var clienteResponse: ClienteResponse? = nil
    @Published var error: String? = nil
    @Published var coupon: Coupon? = nil
    @Published var successMessage: String? = nil
    @Published var usedPromotions: [Int] = []
    
    private let apiServiceCliente: APIServiceCliente
    private var cancellables = Set<AnyCancellable>()

    init(apiServiceCliente: APIServiceCliente = APIServiceCliente()) {
        self.apiServiceCliente = apiServiceCliente
    }

    var formattedNacimiento: String {
        if let nacimiento = clienteResponse?.cliente.nacimiento {
            return formatBirthDate(nacimiento)
        }
        return "No disponible"
    }

    @MainActor
    func fetchCliente(valor: String) async {
        print("ClienteViewModel: Fetching cliente with valor: \(valor)")
        clienteResponse = nil
        error = nil
        if valor.isEmpty {
            error = "Por favor, ingrese un código o RUT"
            return
        }
        do {
            let response = try await apiServiceCliente.getCliente(valor: valor)
            print("ClienteViewModel: ClienteResponse recibido: \(response)")
            response.activePromotions?.forEachIndexed { index, promo in
                print("ClienteViewModel: Promoción \(index): \(promo.name), ID: \(promo.id)")
            }
            clienteResponse = response
            error = nil
        } catch {
            print("ClienteViewModel: Error: \(error.localizedDescription)")
            clienteResponse = nil
            if let apiError = error as? APIError {
                switch apiError {
                case .invalidURL:
                    self.error = "URL inválida."
                case .requestFailed(let underlyingError):
                    if let urlError = underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                        self.error = "Sin conexión a internet."
                    } else {
                        self.error = "Error de solicitud: \(underlyingError.localizedDescription)"
                    }
                case .invalidResponse:
                    self.error = "Respuesta inválida del servidor."
                case .decodingError(let underlyingError):
                    self.error = "Error de decodificación: \(underlyingError.localizedDescription)"
                case .clientNotFound:
                    self.error = "Cliente no existe en la base de datos."
                }
            } else {
                self.error = "Error: \(error.localizedDescription)"
            }        }
    }

    @MainActor
    func generateCoupon(promo: Promotion, rutNumerico: String) async {
        if usedPromotions.contains(promo.id) {
            error = "Ya has generado un cupón para esta promoción. Solo puedes generar uno por promoción."
            return
        }

        do {
            error = nil
            successMessage = nil
            let couponResponse = try await apiServiceCliente.generateCoupon(promoId: promo.id, rutNumerico: rutNumerico.trimmingCharacters(in: .whitespacesAndNewlines))
            let coupon = couponResponse.cupon
            if coupon.qrCode.isEmpty {
                self.coupon = coupon
                successMessage = "¡Cupón otorgado con éxito!"
                usedPromotions.append(promo.id)
                clienteResponse = nil // Limpiar cliente para evitar reutilización
            } else {
                error = "No se pudo obtener el código QR"
            }
        } catch {
            print("ClienteViewModel: Error al generar cupón: \(error.localizedDescription)")
            if let apiError = error as? APIError {
                switch apiError {
                case .invalidURL:
                    self.error = "URL inválida."
                case .requestFailed(let underlyingError):
                    if let urlError = underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                        self.error = "Sin conexión a internet."
                    } else {
                        self.error = "Error de solicitud: \(underlyingError.localizedDescription)"
                    }
                case .invalidResponse:
                    self.error = "Respuesta inválida del servidor."
                case .decodingError(let underlyingError):
                    self.error = "Error de decodificación: \(underlyingError.localizedDescription)"
                case .clientNotFound:
                    self.error = "Cliente no existe en la base de datos."
                }
            } else {
                self.error = "Error al conectar con el servidor: \(error.localizedDescription)"
            }
        }
    }

    func clearCoupon() {
        coupon = nil
        successMessage = nil
    }

    func clearError() {
        error = nil
    }

    func clearSuccessMessage() {
        successMessage = nil
    }

    func clearCliente() {
        clienteResponse = nil
        error = nil
    }

    private func formatBirthDate(_ nacimiento: Int) -> String {
        if nacimiento <= 0 { return "No disponible" }
        let baseDate = Calendar.current.date(from: DateComponents(year: 1800, month: 12, day: 28))!
        if let date = Calendar.current.date(byAdding: .day, value: nacimiento, to: baseDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM"
            return dateFormatter.string(from: date)
        }
        return "No disponible"
    }
}

extension Collection {
    func forEachIndexed(_ body: (Int, Element) throws -> Void) rethrows {
        for (index, element) in enumerated() {
            try body(index, element)
        }
    }
}
