import SwiftUI

struct OrderDetailView: View {
    let order: RequestOrderResponse
    private let apiService = APIService()
    @State private var showPdf = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    OrderHeaderView(order: order)
                    
                    ItemsListView(items: order.items, orderStatus: order.status)
                }
                .padding()
            }
            
            pdfButton
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Detalle del Pedido")
        .sheet(isPresented: $showPdf) {
            if let pdfPath = order.pdfReportUrl, let url = URL(string: apiService.baseUrl + pdfPath) {
                SafariView(url: url)
            }
        }
    }
    
    @ViewBuilder
    private var pdfButton: some View {
        if order.pdfReportUrl != nil {
            Button(action: { showPdf = true }) {
                Image(systemName: "doc.text.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            .padding()
        }
    }
}

struct OrderHeaderView: View {
    let order: RequestOrderResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("PEDIDO #\(order.id)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(order.user.fullName ?? "N/A")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                StatusBadge(status: order.status)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Fecha de Creación", value: formattedDate(from: order.createdAt), icon: "calendar")
                InfoRow(label: "Última Actualización", value: formattedDate(from: order.updatedAt), icon: "arrow.clockwise")
                InfoRow(label: "Prioridad", value: "\(order.priority)", icon: "exclamationmark.triangle")
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func formattedDate(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return "Fecha inválida"
    }
}

struct ItemsListView: View {
    let items: [OrderItemResponse]
    let orderStatus: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Artículos")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(items) { item in
                ItemRow(item: item, orderStatus: orderStatus)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct ItemRow: View {
    let item: OrderItemResponse
    let orderStatus: String
    
    private var progress: Double {
        let lowercasedStatus = orderStatus.lowercased()
        
        if lowercasedStatus == "completado" || lowercasedStatus == "entregada" || lowercasedStatus == "despachada" {
            return 1.0
        }
        
        if lowercasedStatus == "procesando" {
            let calculatedProgress = item.quantityUnits > 0 ? item.quantityUnitsDispatched / item.quantityUnits : 0
            return max(calculatedProgress, 0.5) // At least 50% if processing
        }
        
        // Default calculation based on dispatched quantity for other statuses
        guard item.quantityUnits > 0 else { return 0 }
        return item.quantityUnitsDispatched / item.quantityUnits
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.product.desProducto)
                .font(.headline)
            
            HStack {
                Text("Cajas: \(item.quantityBoxes.formatted(withDecimalPlaces: 2))")
                Spacer()
                Text("Unidades: \(item.quantityUnits.formatted(withDecimalPlaces: 2))")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            ProgressView(value: progress) {
                HStack {
                    Text("Despachado")
                    Spacer()
                    Text("\(Int(progress * 100))%")
                }
            }
            .tint(progressColor)
            .font(.caption)
            
            HStack {
                Text("Cajas Despachadas: \(item.quantityBoxesDispatched.formatted(withDecimalPlaces: 2))")
                Spacer()
                Text("Unidades Despachadas: \(item.quantityUnitsDispatched.formatted(withDecimalPlaces: 2))")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
    
    private var progressColor: Color {
        switch progress {
        case 0: return .red
        case 1: return .green
        default: return .orange
        }
    }
}

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusColor(for: status))
            .clipShape(Capsule())
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pendiente":
            return .orange
        case "procesanda":
            return .blue
        case "completada", "entregada", "despachada":
            return .green
        case "cancelado", "rechazada":
            return .red
        default:
            return .gray
        }
    }
}



struct OrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderDetailView(order: previewOrder)
        }
    }
    
    static var previewOrder: RequestOrderResponse {
        let user = UserResponse(employeeId: "1", username: "jdoe", email: "jdoe@example.com", fullName: "John Doe", createdAt: "2025-10-30T10:00:00Z")
        let product1 = ProductDetailResponse(indexProductos: 1, codProducto: "123", desProducto: "Test Product 1", ultCosto: 10.0, existencias: 100.0)
        let item1 = OrderItemResponse(product: product1, quantityUnits: 10, quantityBoxes: 1, quantityUnitsDispatched: 5, quantityBoxesDispatched: 0)
        let product2 = ProductDetailResponse(indexProductos: 2, codProducto: "456", desProducto: "Test Product 2", ultCosto: 20.0, existencias: 50.0)
        let item2 = OrderItemResponse(product: product2, quantityUnits: 20, quantityBoxes: 2, quantityUnitsDispatched: 20, quantityBoxesDispatched: 2)

        return RequestOrderResponse(
            id: 123,
            user: user,
            createdAt: "2025-10-30T22:23:52.726878-05:00",
            updatedAt: "2025-10-31T10:00:00.000000-05:00",
            status: "Pendiente",
            priority: 1,
            pdfReportUrl: "/media/pedidos_reportes_pdf/Pedido-RL-No-147.pdf",
            items: [item1, item2]
        )
    }
}

