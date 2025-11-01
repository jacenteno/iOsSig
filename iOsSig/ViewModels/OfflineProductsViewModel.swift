import Foundation
import Combine

@MainActor
class OfflineProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false

    private let productRepository: ProductRepository
    private var cancellables = Set<AnyCancellable>()

    init(productRepository: ProductRepository = .shared) {
        self.productRepository = productRepository
        
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.fetchProducts(filter: searchText)
            }
            .store(in: &cancellables)
    }

    func fetchProducts(filter: String) {
        self.isLoading = true
        Task {
            let fetchedProducts = await productRepository.fetchLocalProducts(filter: filter)
            self.products = fetchedProducts
            self.isLoading = false
        }
    }
    
    func onAppear() {
        fetchProducts(filter: "") // Cargar todos los productos inicialmente
    }
}
