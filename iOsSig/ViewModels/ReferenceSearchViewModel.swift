import Combine
import Foundation

@MainActor
class ReferenceSearchViewModel: ObservableObject {
  @Published var referenceQuery: String = ""
      @Published var searchResults: [Productos] = []
      @Published var isLoading: Bool = false
      @Published var errorMessage: String? = nil
      
      private var apiService: APIService
      private var cancellables = Set<AnyCancellable>()
      private var searchTask: Task<Void, Never>?
      
      init(apiService: APIService = APIService()) {
          self.apiService = apiService
          setupBindings()
      }
      
      private func setupBindings() {
          $referenceQuery
              .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
              .removeDuplicates()
              .sink { [weak self] query in
                  guard let self = self else { return }
                  if query.isEmpty {
                      self.searchResults = []
                  } else {
                      self.performSearch(query: query)
                  }
              }
              .store(in: &cancellables)
      }
      
      func performSearch(query: String) {
          guard !query.isEmpty else {
              searchResults = []
              return
          }
          
          isLoading = true
          errorMessage = nil
          searchTask?.cancel()
          
          searchTask = Task {
              do {
                  let referenciaResult = try await apiService.searchProductsByReference(reference: query)
                  if Task.isCancelled { return }
                  self.searchResults = referenciaResult.productos
                  self.isLoading = false
              } catch {
                  if Task.isCancelled { return }
                  self.errorMessage = "Error al buscar referencias: \(error.localizedDescription)"
                  self.isLoading = false
              }
          }
      }}
