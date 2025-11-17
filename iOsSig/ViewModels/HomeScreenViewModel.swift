import Combine
import Foundation

// MARK: - Operator Summary Data Structure
struct OperatorOrderSummary: Identifiable {
  let id = UUID()
  let username: String
  let pendingCount: Int
  let processingCount: Int
}

class HomeScreenViewModel: ObservableObject {
  // Properties from original HomeViewModel for sales data
  @Published var totalMontoFinal: Double = 0.0
  @Published var totalClientes: Int = 0
  @Published var totalFacturaDelMes: Double = 0.0
  @Published var ventaPorHoraGeneral: [String: SalesByHourItem] = [:]

  // Properties for Request Orders
  @Published var orders: [RequestOrderResponse] = []
  @Published var receptionPendingCount: Int = 0

  // Property for operator summary
  @Published var operatorSummary: [OperatorOrderSummary] = []

  @Published var isLoading: Bool = false
  @Published var error: String? = nil

  // Computed properties for orders
  var pendingOrderCount: Int {
    orders.filter { $0.status.lowercased() == "pendiente" }.count
  }

  var processingOrderCount: Int {
    orders.filter { $0.status.lowercased() == "procesando" }.count
  }

  // MARK: - Chart-Ready Computed Properties

  var salesByHourForChart: [ChartableSalesByHour] {
    // Sort by hour to ensure the chart follows the time of day
    ventaPorHoraGeneral.map { hour, item in
      ChartableSalesByHour(hour: hour, amount: item.monto)
    }.sorted { $0.hour < $1.hour }
  }

  private let apiService: APIService
  private var timer: AnyCancellable?

  init() {
    self.apiService = APIService()
  }

  deinit {
    timer?.cancel()
  }

  func fetchAllData() {
    if isLoading {
      return
    }
    isLoading = true
    error = nil

    Task {
      // Fetch all data types concurrently
      async let salesDataTask = fetchSalesData()
      async let ordersTask = fetchOrders()
      async let receiptsTask = fetchPendingReceipts()

      // Await results
      _ = await salesDataTask
      _ = await ordersTask
      _ = await receiptsTask

      DispatchQueue.main.async {
        self.isLoading = false
      }
    }
  }

  func fetchPrimaryData() {
    // This function is for the initial, fast load.
    // We only fetch the most critical data to display first.
    if isLoading { return }
    isLoading = true
    error = nil

    Task {
      await fetchSalesData()
      DispatchQueue.main.async {
        self.isLoading = false
      }
    }
  }

  func fetchSecondaryData() {
    // This fetches less critical data in the background
    // so the main UI is already interactive.
    Task {
      async let ordersTask = fetchOrders()
      async let receiptsTask = fetchPendingReceipts()

      _ = await ordersTask
      _ = await receiptsTask
    }
  }

  private func fetchSalesData() async {
    do {
      let salesData = try await apiService.getOnlineSalesData()
      DispatchQueue.main.async {
        self.totalMontoFinal = salesData.totalMontoFinal ?? 0.0
        self.totalClientes = salesData.totalClientes ?? 0
        self.totalFacturaDelMes = salesData.totalFacturaDelMes ?? 0.0
        self.ventaPorHoraGeneral = salesData.ventaPorHoraGeneral ?? [:]
      }
    } catch {
      DispatchQueue.main.async {
        self.error = "No se pudieron cargar los datos de ventas."
      }
    }
  }

  private func fetchOrders() async {
    let statusesToFetch = ["pendiente", "procesando"]
    let date30DaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!

    do {
      let fetchedOrders = try await apiService.fetchAllRequests(
        statuses: statusesToFetch, createdAfter: date30DaysAgo)

      // Group orders by username
      let groupedByUsername = Dictionary(grouping: fetchedOrders, by: { $0.user.username })

      let summary = groupedByUsername.map { (username, orders) -> OperatorOrderSummary in
        let pending = orders.filter { $0.status.lowercased() == "pendiente" }.count
        let processing = orders.filter { $0.status.lowercased() == "procesando" }.count
        return OperatorOrderSummary(
          username: username, pendingCount: pending, processingCount: processing)
      }.sorted { $0.username < $1.username }  // Sort alphabetically by username

      DispatchQueue.main.async {
        self.orders = fetchedOrders
        self.operatorSummary = summary
        print(
          "HomeScreenViewModel: Fetched and processed \(self.orders.count) active request orders.")
      }
    } catch {
      DispatchQueue.main.async {
        // This error is less critical for the UI, so we can just log it
        print("HomeScreenViewModel: Failed to fetch request orders: \(error.localizedDescription)")
      }
    }
  }

  private func fetchPendingReceipts() async {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: Date())
    guard let startOfMonth = calendar.date(from: components) else { return }

    do {
      let paginatedResponse = try await apiService.fetchReceipts(
        status: "pendiente", createdAfter: startOfMonth)
      DispatchQueue.main.async {
        self.receptionPendingCount = paginatedResponse.count
      }
    } catch {
      DispatchQueue.main.async {
        print(
          "HomeScreenViewModel: Failed to fetch pending receipts: \(error.localizedDescription)")
      }
    }
  }

}
