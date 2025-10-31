import Foundation
import Combine

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var productSource: DataSource? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var productRepository: ProductRepository
    private var apiService: APIService // Keep for list fetching for now
    private var settings: SettingsManager
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private var justSearchedByCode = false

    @Published var searchQuery: String = ""
    @Published var selectedFilterType: String = "Código"
    @Published var showCreateProductAlert = false
    @Published var productNotFoundCode: String?

    private var currentPage = 1
    @Published var canLoadMorePages = true

    init(productRepository: ProductRepository = ProductRepository(), apiService: APIService = APIService(), settings: SettingsManager = .shared) {
        self.productRepository = productRepository
        self.apiService = apiService
        self.settings = settings
        setupBindings()
    }

    private func setupBindings() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self, self.selectedFilterType != "Código" else { return }
                if self.justSearchedByCode {
                    self.justSearchedByCode = false
                    return
                }
                self.fetchProducts()
            }
            .store(in: &cancellables)

        $selectedFilterType
            .sink { [weak self] _ in
                self?.fetchProducts()
            }
            .store(in: &cancellables)
    }

    func searchProductByCode() {
        guard !searchQuery.isEmpty, selectedFilterType == "Código" else { return }
        fetchProducts()
    }

    func fetchProducts() {
        print("Fetching products...")
        searchTask?.cancel()
        products.removeAll()
        productSource = nil
        currentPage = 1
        canLoadMorePages = true
        loadMoreProducts()
    }

    func loadMoreProducts() {
        print("Loading more products...")
        guard canLoadMorePages else {
            print("Cannot load more pages. canLoadMorePages: \(canLoadMorePages)")
            return
        }
        
        if searchQuery.isEmpty && selectedFilterType != "Todos" {
            self.products = []
            return
        }

        isLoading = true
        errorMessage = nil

        searchTask = Task {
            do {
                if selectedFilterType == "Código" {
                    print("Fetching product by code: \(searchQuery) from repository")
                    let (product, source) = try await productRepository.getProduct(byCode: searchQuery)
                    print("Product fetched from \(source): \(product)")

                    self.products = [product]
                    self.productSource = source
                    self.canLoadMorePages = false
                    self.isLoading = false
                    self.searchQuery = ""
                    self.justSearchedByCode = true
                    return
                } else {
                    // TODO: Refactor list fetching to use the repository as well.
                    // For now, we use the old API service call.
                    if Task.isCancelled { return }
                    print("Client-side filtering for \(selectedFilterType). This is not optimal.")
                    
                    let paginatedResponse = try await apiService.getProducts(page: currentPage)
                    let filteredProducts = paginatedResponse.results.filter { product in
                        filterProduct(product)
                    }
                    
                    if Task.isCancelled { return }
                    self.products.append(contentsOf: filteredProducts)
                    self.productSource = .api // Assume API for list
                    self.currentPage += 1
                    self.canLoadMorePages = paginatedResponse.next != nil
                    self.isLoading = false
                }
            } catch {
                if Task.isCancelled {
                    print("Search task cancelled.")
                    return
                }
                if case let APIError.serverError(statusCode) = error, statusCode == 404 {
                    guard settings.userRole.hasPermission("CREAR_PRODUCTO") else {
                        self.errorMessage = "Producto no encontrado."
                        return
                    }
                    self.productNotFoundCode = self.searchQuery
                    self.showCreateProductAlert = true
                    self.errorMessage = nil // No need to show a generic error message
                } else {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
    
    private func filterProduct(_ product: Product) -> Bool {
        switch self.selectedFilterType {
        case "Nombre":
            return product.desproducto?.localizedCaseInsensitiveContains(self.searchQuery) ?? false
        case "Referencia":
            return product.codigobarra?.lowercased().hasPrefix(self.searchQuery.lowercased()) ?? false
        default:
            return false
        }
    }

    func clearSearch() {
        products = []
        productSource = nil
        searchQuery = ""
        errorMessage = nil
    }

    func showProductAsSingleResult(_ product: Product) {
        guard let codproducto = product.codproducto else { return }
        
        searchTask?.cancel()
        
        products = [product]
        selectedFilterType = "Código"
        
        justSearchedByCode = true
        searchQuery = codproducto.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

