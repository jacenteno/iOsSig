import Combine
import Foundation

@MainActor
class SyncProductsViewModel: ObservableObject {
  static let shared = SyncProductsViewModel()

  // Estado de la UI
  @Published var isLoading = false
  @Published var isSyncing = false
  @Published var syncMessage = "Listo para sincronizar."
  @Published var syncProgress: Double = 0.0
  @Published var totalItemsToSync: Int = 0
  @Published var newItemsSynced: Int = 0
  @Published var errorMessage: String?
  @Published var localProductsCount = 0

  // Datos
  @Published var departments: [Departamento] = []
  @Published var selectedDepartmentIDs = Set<Int>()

  // Dependencias
  private let apiService: APIService
  private let productRepository: ProductRepository

  private var cancellables = Set<AnyCancellable>()
  private var syncTask: Task<Void, Error>?

  private init(
    apiService: APIService = APIService.shared,
    productRepository: ProductRepository = ProductRepository.shared
  ) {
    self.apiService = apiService
    self.productRepository = productRepository

    // Observar cambios en el repositorio para actualizar el conteo
    productRepository.$totalProductsCount
      .receive(on: RunLoop.main)
      .assign(to: \.localProductsCount, on: self)
      .store(in: &cancellables)
  }

  func cancelSync() {
    syncTask?.cancel()
  }

  func selectAllDepartments() {
    selectedDepartmentIDs = Set(departments.map { $0.coddepartamento })
  }

  func deselectAllDepartments() {
    selectedDepartmentIDs.removeAll()
  }

  func onAppear() {
    Task {
      await fetchDepartments()
      await updateLocalProductsCount()
    }
  }

  func fetchDepartments() async {
    guard departments.isEmpty else { return }  // No volver a cargar si ya existen

    self.isLoading = true
    self.errorMessage = nil

    do {
      let response = try await apiService.getDepartamentos()
      self.departments = response.results
      self.isLoading = false
    } catch {
      self.errorMessage = "Error al cargar departamentos: \(error.localizedDescription)"
      self.isLoading = false
    }
  }

  func syncProducts() {
    guard !selectedDepartmentIDs.isEmpty else {
      self.errorMessage = "Por favor, seleccione al menos un departamento."
      return
    }

    // Reset states
    isSyncing = true
    syncProgress = 0.0
    newItemsSynced = 0
    totalItemsToSync = 0
    syncMessage = "Calculando total de productos..."
    errorMessage = nil

    syncTask = Task {
      let selectedIDsArray = Array(selectedDepartmentIDs)

      do {
        // 1. Pre-flight: Calcular el total de productos a sincronizar
        try await withThrowingTaskGroup(of: Int.self) {
          group in
          for deptId in selectedIDsArray {
            group.addTask {
              let response = try await self.apiService.getProductsByDepartment(
                coddep: String(deptId), page: 1)
              return response.count
            }
          }

          var totalCount = 0
          for try await count in group {
            totalCount += count
          }
          await MainActor.run { self.totalItemsToSync = totalCount }
        }

        // 2. Limpiar productos existentes
        try Task.checkCancellation()
        await MainActor.run { syncMessage = "Limpiando productos antiguos..." }
        for deptId in selectedIDsArray {
          if let deptName = departments.first(where: { $0.coddepartamento == deptId })?.nomdepto {
            try await productRepository.deleteProducts(byDepartment: deptName)
          }
        }

        // 3. Iniciar la descarga
        for deptId in selectedIDsArray {
          try Task.checkCancellation()
          guard let deptName = departments.first(where: { $0.coddepartamento == deptId })?.nomdepto
          else { continue }

          var currentPage = 1
          var hasNextPage = true

          while hasNextPage {
            try Task.checkCancellation()
            let response = try await apiService.getProductsByDepartment(
              coddep: String(deptId), page: currentPage)

            await productRepository.saveProducts(response.results)

            let newCount = self.newItemsSynced + response.results.count
            await MainActor.run {
              self.newItemsSynced = newCount
              if self.totalItemsToSync > 0 {
                self.syncProgress = Double(newCount) / Double(self.totalItemsToSync)
              }
              self.syncMessage = "Procesando \(newCount) de \(self.totalItemsToSync)..."
            }

            if response.next != nil {
              currentPage += 1
            } else {
              hasNextPage = false
            }
          }
        }

        await MainActor.run {
          syncMessage =
            "¡Sincronización completada! Se procesaron \(self.newItemsSynced) productos."
          isSyncing = false
        }
        await updateLocalProductsCount()

      } catch is CancellationError {
        await MainActor.run {
          syncMessage = "Sincronización cancelada."
          isSyncing = false
        }
      } catch {
        await MainActor.run {
          self.errorMessage = "Ocurrió un error: \(error.localizedDescription)"
          syncMessage = "Error en la sincronización."
          isSyncing = false
        }
      }
    }
  }

  func updateLocalProductsCount() async {
    await productRepository.fetchTotalProductsCount()
  }
}
