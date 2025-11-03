import Foundation
import Combine

@MainActor
class HacerPedidosViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSuccess = false
    @Published var operatorDetail: Operator?

    private let apiService = APIService()
    private var settings: SettingsManager

    init(settings: SettingsManager = .shared) {
        self.settings = settings
    }

    func fetchOperatorDetails() async {
        let operatorId = settings.operadorCode
        guard operatorId > 0 else {
            alertMessage = "ID de operador no configurado."
            showAlert = true
            return
        }

        isLoading = true
        do {
            operatorDetail = try await apiService.getOperatorById(operatorId: operatorId)
        } catch {
            alertMessage = "Error al cargar los detalles del operador: \(error.localizedDescription)"
            showAlert = true
        }
        isLoading = false
    }

    func createOrder(cartManager: CartManager) async {
        // 1. Fetch operator details first
        await fetchOperatorDetails()
        
        guard let fetchedOperator = operatorDetail else {
            return
        }

        guard !cartManager.items.isEmpty else {
            alertMessage = "No hay productos en el pedido."
            showAlert = true
            return
        }

        isLoading = true

        let orderItems = cartManager.items.map {
            CreateOrderItem(productId: $0.product.indexproductos ?? 0, quantityUnits: Double($0.unidades), quantityBoxes: Double($0.cajas))
        }

        let orderRequest = CreateOrderRequest(
            employeeId: fetchedOperator.employeeId,
            status: "pendiente",
            priority: 1,
            items: orderItems
        )
        
        do {
            let createdOrder = try await apiService.createRequestOrder(orderRequest: orderRequest)
            alertMessage = "Pedido #\(createdOrder.id) creado exitosamente."
            isSuccess = true
            showAlert = true
        } catch {
            alertMessage = "Error al crear el pedido: \(error.localizedDescription)"
            isSuccess = false
            showAlert = true
        }

        isLoading = false
    }
}
