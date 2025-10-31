import SwiftUI

struct OrdersListScreen: View {
    @StateObject private var viewModel = OrdersListViewModel()
    @State private var showError = false
    @State private var showFilters = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                VStack {
                    filterControls
                    content
                }
            }
            .navigationTitle("Mis Pedidos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            showFilters.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolVariant(showFilters ? .fill : .none)
                    }
                }
            }
            .onAppear {
                viewModel.fetchOrders()
            }
            .onChange(of: viewModel.state) { newState, oldState in
                if case .error = newState {
                    showError = true
                } else {
                    showError = false
                }
            }
        }
    }

    @ViewBuilder
    private var filterControls: some View {
        if showFilters {
            VStack(spacing: 16) {
                Picker("Estado", selection: $viewModel.selectedStatusFilter) {
                    ForEach(OrderStatusFilter.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                HStack {
                    DatePicker("Desde", selection: $viewModel.startDate, displayedComponents: .date)
                    DatePicker("Hasta", selection: $viewModel.endDate, displayedComponents: .date)
                }
                
                SearchBar(text: $viewModel.searchText)
            }
            .padding()
            .background(.bar)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .loaded(let orders):
            if orders.isEmpty {
                emptyState
            } else {
                List(orders) { order in
                    ZStack {
                        OrderRow(order: order)
                        NavigationLink(destination: OrderDetailView(order: order)) {
                           EmptyView()
                        }
                        .opacity(0)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.fetchOrders()
                }
            }
        case .error(let errorMessage):
            if showError {
                ErrorView(errorMessage: errorMessage, retryAction: viewModel.fetchOrders, isShowingError: $showError)
            } else {
                EmptyView()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "shippingbox.circle")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            Text("No hay pedidos")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Cuando crees un pedido, aparecerá aquí.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Refrescar") {
                viewModel.fetchOrders()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct OrderRow: View {
    let order: RequestOrderResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pedido #\(order.id)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(order.user.fullName ?? "N/A")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                statusBadge
            }
            
            Divider()
            
            HStack {
                Label(formattedDate(from: order.createdAt), systemImage: "calendar")
                Spacer()
                Label("\(order.items.count) items", systemImage: "archivebox")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var statusBadge: some View {
        Text(order.status.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusColor(for: order.status))
            .clipShape(Capsule())
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

    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pendiente":
            return .orange
        case "procesando":
            return .blue
        case "completado", "entregada", "despachada":
            return .green
        case "cancelado", "rechazada":
            return .red
        default:
            return .gray
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Buscar por ID o solicitante...", text: $text)
                .padding(12)
                .padding(.horizontal, 28)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
    }
}


struct OrdersListScreen_Previews: PreviewProvider {
    static var previews: some View {
        OrdersListScreen()
    }
}