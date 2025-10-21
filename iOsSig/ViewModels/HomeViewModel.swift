import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var ventaPorGrupoCaja: [String: SalesSummaryItem] = [:]
    @Published var ventaPorHoraGeneral: [String: SalesByHourItem] = [:]
    @Published var ventaPorGrupoCajaDetalle: [String: AreaDetail] = [:]
    @Published var totalFacturas: Int = 0
    @Published var totalMontoIngreso: Double = 0.0
    @Published var totalMontoEgreso: Double = 0.0
    @Published var totalTransacciones: Int = 0
    @Published var totalMontoFinal: Double = 0.0
    @Published var finalDescuento: Double = 0.0
    @Published var totalNotasCredito: Double = 0.0

    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    // MARK: - Chart-Ready Computed Properties

    struct ChartableSalesByHour: Identifiable {
        let id = UUID()
        let hour: String
        let amount: Double
    }

    var salesByAreaForChart: [SalesSummaryItem] {
        // Sort by amount descending to show the most important areas first
        ventaPorGrupoCaja.values.sorted { $0.monto > $1.monto }
    }

    var salesByHourForChart: [ChartableSalesByHour] {
        // Sort by hour to ensure the chart follows the time of day
        ventaPorHoraGeneral.map { hour, item in
            ChartableSalesByHour(hour: hour, amount: item.monto)
        }.sorted { $0.hour < $1.hour }
    }

    private let apiService: APIService
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
        fetchSalesData() // Fetch data immediately on init
        startTimer()
    }

    deinit {
        stopTimer()
    }

    func startTimer() {
        stopTimer()
        timer = Timer.publish(every: 45, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                print("Timer fired. Fetching sales data...")
                self?.fetchSalesData()
            }
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    func fetchSalesData() {
        if isLoading {
            print("HomeViewModel: fetchSalesData ignored, already loading.")
            return
        }

        isLoading = true
        error = nil

        Task {
            do {
                print("HomeViewModel: Starting API call to get dashboard data...")
                let salesData = try await apiService.getOnlineSalesData() // Assuming APIService has this method

                DispatchQueue.main.async {
                    self.ventaPorGrupoCaja = salesData.ventaPorGrupoCaja
                    self.ventaPorHoraGeneral = salesData.ventaPorHoraGeneral
                    self.ventaPorGrupoCajaDetalle = salesData.ventaPorGrupoCajaDetalle
                    self.totalFacturas = salesData.totalFacturas
                    self.totalMontoIngreso = salesData.totalMontoIngreso
                    self.totalMontoEgreso = salesData.totalMontoEgreso
                    self.totalTransacciones = salesData.totalTransacciones
                    self.totalMontoFinal = salesData.totalMontoFinal
                    self.finalDescuento = salesData.finalDescuento
                    self.totalNotasCredito = salesData.totalMontoNotaCredito
                    self.isLoading = false
                    print("HomeViewModel: Dashboard data received and parsed successfully!")
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = "Failed to fetch sales data: \(error.localizedDescription)"
                    self.isLoading = false
                    print("HomeViewModel: Critical failure in API call: \(error)")
                }
            }
        }
    }
}
