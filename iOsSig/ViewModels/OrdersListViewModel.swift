import Foundation
import Combine

// MARK: - State Management
enum OrdersListState: Equatable {
    case idle
    case loading
    case loaded([RequestOrderResponse])
    case error(String)
}

// MARK: - Filter Options
enum OrderStatusFilter: String, CaseIterable, Identifiable {
    case all = "Todos"
    case pending = "Pendiente"
    case processing = "Procesando"
    case completed = "Completado"
    case cancelled = "Cancelado"

    var id: String { self.rawValue }
}

@MainActor
class OrdersListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var state: OrdersListState = .idle
    @Published var orders: [RequestOrderResponse] = []
    @Published var filteredOrders: [RequestOrderResponse] = []
    @Published var selectedStatusFilter: OrderStatusFilter = .all {
        didSet {
            applyFilters()
        }
    }
    @Published var startDate = Calendar.current.startOfDay(for: Date()) {
        didSet {
            applyFilters()
        }
    }
    @Published var endDate: Date = {
        let today = Date()
        return Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: today))!.addingTimeInterval(-1)
    }() {
        didSet {
            applyFilters()
        }
    }
    @Published var searchText = "" {
        didSet {
            applyFilters()
        }
    }

    // MARK: - Private Properties
    private let apiService: APIService
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?

    // MARK: - Initialization
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
        
        let today = Date()
        self.startDate = Calendar.current.startOfDay(for: today)
        self.endDate = Calendar.current.date(byAdding: .day, value: 1, to: self.startDate)!.addingTimeInterval(-1)

        startAutoRefresh()
    }

    // MARK: - Public Methods
    func fetchOrders() {
        state = .loading
        print("--- Fetching Orders ---")
        Task {
            do {
                let fetchedOrders = try await apiService.fetchAllRequests()
                print("Fetched \(fetchedOrders.count) orders")
                for order in fetchedOrders {
                    print("Order ID: \(order.id), Date: \(order.createdAt), Status: \(order.status)")
                }
                self.orders = fetchedOrders.sorted(by: { $0.createdAt > $1.createdAt })
                applyFilters()
                self.state = .loaded(self.filteredOrders)
                print("--- Finished Fetching Orders ---")
            } catch {
                print("Error fetching orders: \(error.localizedDescription)")
                self.state = .error("Error fetching orders: \(error.localizedDescription)")
            }
        }
    }

    func startAutoRefresh(interval: TimeInterval = 30) {
        timer?.cancel() // Cancel any existing timer
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchOrders()
            }
    }

    func stopAutoRefresh() {
        timer?.cancel()
    }

    // MARK: - Private Helper Methods
    private func applyFilters() {
        print("--- Applying Filters ---")
        print("Total orders: \(orders.count)")
        print("Selected status: \(selectedStatusFilter.rawValue)")
        print("Start date: \(startDate)")
        print("End date: \(endDate)")
        print("Search text: \(searchText)")

        var tempFiltered = orders

        // Filter by status
        if selectedStatusFilter != .all {
            tempFiltered = tempFiltered.filter { $0.status.lowercased() == selectedStatusFilter.rawValue.lowercased() }
            print("After status filter: \(tempFiltered.count) orders")
        }

        // Filter by date range
        tempFiltered = tempFiltered.filter { order in
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            guard let orderDate = formatter.date(from: order.createdAt) else {
                print("Could not parse date: \(order.createdAt)")
                return false
            }
            
            let startOfDay = Calendar.current.startOfDay(for: startDate)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: endDate))!

            let isWithinRange = orderDate >= startOfDay && orderDate < endOfDay
            print("Order ID: \(order.id), Order Date: \(orderDate), Start of Day: \(startOfDay), End of Day: \(endOfDay), Is Within Range: \(isWithinRange)")

            return isWithinRange
        }
        print("After date filter: \(tempFiltered.count) orders")
        
        // Filter by search text
        if !searchText.isEmpty {
            tempFiltered = tempFiltered.filter { order in
                order.id.description.contains(searchText) ||
                (order.user.fullName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
            print("After search text filter: \(tempFiltered.count) orders")
        }

        filteredOrders = tempFiltered
        if case .loaded = state {
            state = .loaded(filteredOrders)
        }
        print("Final filtered orders: \(filteredOrders.count)")
        print("--- Filters Applied ---")
    }
}