import Combine
import Foundation

class HomeViewModel: ObservableObject {
  @Published var ventaPorGrupoCaja: [String: SalesSummaryItem] = [:]
  @Published var ventaPorHoraGeneral: [String: SalesByHourItem] = [:]
  @Published var ventaPorGrupoCajaDetalle: [String: AreaDetail] = [:]
  @Published var totalTickets: Int = 0  // Renamed from totalFacturas
  @Published var totalFacturaDelMes: Double = 0.0
  @Published var totalClientes: Int = 0
  @Published var ventaPorHora: [String: [String: SalesByHourDetailItem]] = [:]
  @Published var ventaPorCaja: [String: CashRegisterSummaryItem] = [:]
  @Published var totalesPorCaja2: [String: CashRegisterSummaryItem] = [:]
  @Published var fechaClarion: Int = 0
  @Published var fechaWeb: String = ""
  @Published var ventaNotaDeCredito: [String: VentaNotaDeCreditoItem] = [:]
  @Published var totalTransaNotaDeCredito: Int = 0
  @Published var totalCajasNotaDeCredito: Int = 0
  @Published var totalMontoIngreso: Double = 0.0
  @Published var totalMontoEgreso: Double = 0.0
  @Published var totalTransacciones: Int = 0
  @Published var totalMontoFinal: Double = 0.0
  @Published var ventaIngreso: [String: VentaIngresoItem] = [:]
  @Published var ventaEgreso: [String: VentaEgresoItem] = [:]
  @Published var totalTransaEgreso: Int = 0
  @Published var totalTransaIngreso: Int = 0
  @Published var totalCajasIngreso: Int = 0
  @Published var totalCajasEgreso: Int = 0
  @Published var totalDescuentos: TotalDescuentosItem = TotalDescuentosItem(
    totalTransacciones: 0, totalDescuento: 0.0)
  @Published var totalDescuentos2: TotalDescuentos2Item = TotalDescuentos2Item(
    totalTransacciones: 0, totalDescuento: 0.0)
  @Published var finalDescuento: Double = 0.0
  @Published var totalCajasGrupo: Int = 0
  @Published var totalTransaccionCajaGrupo: Int = 0
  @Published var totalMontoCajaGrupo: Double = 0.0
  @Published var totalCajas: Int = 0
  @Published var totalTransaccionCaja: Int = 0
  @Published var totalMontoCaja: Double = 0.0
  @Published var totalMontoNotaCredito: Double = 0.0  // Renamed from totalNotasCredito
  @Published var products: [Product] = []

  @Published var isLoading: Bool = false
  @Published var error: String? = nil

  // MARK: - Chart-Ready Computed Properties

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

  var allCashRegistersForChart: [CashRegisterDetail] {
    var allRegisters: [CashRegisterDetail] = []
    for areaDetail in ventaPorGrupoCajaDetalle.values {
      for registerDetail in areaDetail.cajas.values {
        allRegisters.append(registerDetail)
      }
    }
    return allRegisters.sorted { $0.nombre < $1.nombre }  // Sort by name for consistent chart display
  }

  private let apiService: APIService
  private var cancellables = Set<AnyCancellable>()
  private var timer: AnyCancellable?

  init() {
    self.apiService = APIService()
    // startTimer() // Disabled to improve performance and prevent excessive background fetching. User can still pull-to-refresh.
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
        let salesData = try await apiService.getOnlineSalesData()  // Assuming APIService has this method

        DispatchQueue.main.async {
          self.ventaPorGrupoCaja = salesData.ventaPorGrupoCaja ?? [:]
          self.ventaPorHoraGeneral = salesData.ventaPorHoraGeneral ?? [:]
          print(
            "HomeViewModel: ventaPorHoraGeneral populated with \(self.ventaPorHoraGeneral.count) items."
          )
          self.ventaPorGrupoCajaDetalle = salesData.ventaPorGrupoCajaDetalle ?? [:]
          self.totalTickets = salesData.totalTickets ?? 0  // Renamed
          self.totalFacturaDelMes = salesData.totalFacturaDelMes ?? 0.0
          self.totalClientes = salesData.totalClientes ?? 0
          self.ventaPorHora = salesData.ventaPorHora ?? [:]
          self.ventaPorCaja = salesData.ventaPorCaja ?? [:]
          self.totalesPorCaja2 = salesData.totalesPorCaja2 ?? [:]
          self.fechaClarion = salesData.fechaClarion ?? 0
          self.fechaWeb = salesData.fechaWeb ?? ""
          self.ventaNotaDeCredito = salesData.ventaNotaDeCredito ?? [:]
          self.totalTransaNotaDeCredito = salesData.totalTransaNotaDeCredito ?? 0
          self.totalCajasNotaDeCredito = salesData.totalCajasNotaDeCredito ?? 0
          self.totalMontoIngreso = salesData.totalMontoIngreso ?? 0.0
          self.totalMontoEgreso = salesData.totalMontoEgreso ?? 0.0
          self.totalTransacciones = salesData.totalTransacciones ?? 0
          self.totalMontoFinal = salesData.totalMontoFinal ?? 0.0
          self.ventaIngreso = salesData.ventaIngreso ?? [:]
          self.ventaEgreso = salesData.ventaEgreso ?? [:]
          self.totalTransaEgreso = salesData.totalTransaEgreso ?? 0
          self.totalTransaIngreso = salesData.totalTransaIngreso ?? 0
          self.totalCajasIngreso = salesData.totalCajasIngreso ?? 0
          self.totalCajasEgreso = salesData.totalCajasEgreso ?? 0
          self.totalDescuentos =
            salesData.totalDescuentos
            ?? TotalDescuentosItem(totalTransacciones: 0, totalDescuento: 0.0)
          self.totalDescuentos2 =
            salesData.totalDescuentos2
            ?? TotalDescuentos2Item(totalTransacciones: 0, totalDescuento: 0.0)
          self.finalDescuento = salesData.finalDescuento ?? 0.0
          self.totalCajasGrupo = salesData.totalCajasGrupo ?? 0
          self.totalTransaccionCajaGrupo = salesData.totalTransaccionCajaGrupo ?? 0
          self.totalMontoCajaGrupo = salesData.totalMontoCajaGrupo ?? 0.0
          self.totalCajas = salesData.totalCajas ?? 0
          self.totalTransaccionCaja = salesData.totalTransaccionCaja ?? 0
          self.totalMontoCaja = salesData.totalMontoCaja ?? 0.0
          // self.totalMontoNotaCredito = salesData.totalMontoNotaCredito // Renamed
          self.isLoading = false
          print("HomeViewModel: Dashboard data received and parsed successfully!")
        }
      } catch {
        print("HomeViewModel: Primary API call failed, attempting to fetch products...")
        fetchProducts()
      }
    }
  }

  func fetchProducts() {
    Task {
      do {
        let paginatedResponse = try await apiService.getProducts(page: 1)
        DispatchQueue.main.async {
          self.products = paginatedResponse.results
          self.isLoading = false
          self.error = "Fallo al cargar los datos de ventas. Mostrando productos como fallback."
        }
      } catch {
        DispatchQueue.main.async {
          self.error = "Fallo al cargar los datos de ventas y productos."
          self.isLoading = false
        }
      }
    }
  }
}
