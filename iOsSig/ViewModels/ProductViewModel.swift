import Foundation
import Combine

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var ventas: [String: Venta] = [:]
    @Published var citymallProds: [String: Resultado] = [:]
    
    private var apiService: APIService
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private var justSearchedByCode = false

    @Published var searchQuery: String = ""
    @Published var selectedFilterType: String = "Código"
    
    private var currentPage = 1
    @Published var canLoadMorePages = true

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
        setupBindings()
    }

    private func setupBindings() {
        print("Setting up bindings...")
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                if self.justSearchedByCode {
                    self.justSearchedByCode = false
                    return
                }
                print("Search query changed: \(query)")
                self.fetchProducts()
            }
            .store(in: &cancellables)

        $selectedFilterType
            .sink { [weak self] filter in
                print("Filter type changed: \(filter)")
                self?.fetchProducts()
            }
            .store(in: &cancellables)
    }

    func fetchProducts() {
        print("Fetching products...")
        searchTask?.cancel()
        self.products = []
        self.currentPage = 1
        self.canLoadMorePages = true
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
                switch selectedFilterType {
                case "Todos":
                    let paginatedResponse = try await apiService.getProducts(page: currentPage)
                    DispatchQueue.main.async {
                        self.products.append(contentsOf: paginatedResponse.results)
                        self.currentPage += 1
                        self.canLoadMorePages = paginatedResponse.next != nil
                        self.isLoading = false
                    }
                case "Código":
                    print("Fetching product by code: \(searchQuery)")
                    let product = try await apiService.getProductByCode(codigo: searchQuery)
                    print("Product fetched: \(product)")

                    // Immediately update the UI with the main product
                    DispatchQueue.main.async {
                        self.products = [product]
                        self.canLoadMorePages = false
                        self.isLoading = false
                        self.justSearchedByCode = true
                        self.searchQuery = ""
                    }
                    
                    fetchProductDetails(for: product)
                    return
                default:
                    if Task.isCancelled { return }
                    print("Client-side filtering for \(selectedFilterType). This is not optimal.")
                    
                    let paginatedResponse = try await apiService.getProducts(page: currentPage)
                    let filteredProducts = paginatedResponse.results.filter { product in
                        filterProduct(product)
                    }
                    
                    if Task.isCancelled { return }
                    DispatchQueue.main.async {
                        self.products.append(contentsOf: filteredProducts)
                        self.currentPage += 1
                        self.canLoadMorePages = paginatedResponse.next != nil
                        self.isLoading = false
                    }
                    
                    if paginatedResponse.next != nil {
                        await self.fetchAllRemainingPages()
                    }
                }
            } catch {
                if Task.isCancelled {
                    print("Search task cancelled.")
                    return
                }
                DispatchQueue.main.async {
                    if let apiError = error as? APIError {
                        self.errorMessage = apiError.localizedDescription
                    } else {
                        self.errorMessage = "Error desconocido: \(error.localizedDescription)"
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    func fetchProductDetails(for product: Product) {
        guard let codproducto = product.codproducto, let codigobarra = product.codigobarra else {
            return
        }

        if ventas[codproducto] != nil {
            return
        }

        Task {
            print("Fetching details for product: \(codproducto)")
            let venta = try? await apiService.getVentasMensuales(codproducto: codproducto)
            let citymallProd = try? await apiService.getCitymallProduct(barCode: codigobarra)
            
            DispatchQueue.main.async {
                if let venta = venta {
                    self.ventas[codproducto] = venta
                }
                if let citymallProd = citymallProd {
                    self.citymallProds[codproducto] = citymallProd
                }
            }
        }
    }

    private func fetchAllRemainingPages() async {
        while canLoadMorePages && !Task.isCancelled {
            do {
                let paginatedResponse = try await apiService.getProducts(page: currentPage)
                let filteredProducts = paginatedResponse.results.filter { product in
                    filterProduct(product)
                }
                
                if Task.isCancelled { return }
                DispatchQueue.main.async {
                    self.products.append(contentsOf: filteredProducts)
                    self.currentPage += 1
                    self.canLoadMorePages = paginatedResponse.next != nil
                }
            } catch {
                if Task.isCancelled { return }
                DispatchQueue.main.async {
                    self.canLoadMorePages = false
                }
                break
            }
        }
    }
    
    private func filterProduct(_ product: Product) -> Bool {
        switch self.selectedFilterType {
        case "Nombre":
            return product.desproducto?.localizedCaseInsensitiveContains(self.searchQuery) ?? false
        case "Referencia":
            return product.codigobarra?.lowercased().hasPrefix(self.searchQuery.lowercased()) ?? false
        case "Departamento":
            return product.nombre_departamento?.localizedCaseInsensitiveContains(self.searchQuery) ?? false
        case "Proveedor":
            return product.codproveedor.map { String($0) }?.localizedCaseInsensitiveContains(self.searchQuery) ?? false
        case "Bodega":
            return product.codbodega?.localizedCaseInsensitiveContains(self.searchQuery) ?? false
        default:
            return false
        }
    }

    func clearSearch() {
        products = []
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
        
        fetchProductDetails(for: product)
    }
}
