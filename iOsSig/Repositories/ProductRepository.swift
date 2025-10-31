import Foundation
import os.log

enum DataSource {
    case api
    case local
}

class ProductRepository {
    private let apiService: APIService
    private let coreDataStack: CoreDataStack
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "ProductRepository")

    init(apiService: APIService = APIService(), coreDataStack: CoreDataStack = .shared) {
        self.apiService = apiService
        self.coreDataStack = coreDataStack
    }

    func getProduct(byCode code: String) async throws -> (product: Product, source: DataSource) {
        logger.info("🚀 getProduct(byCode: \(code)) - Starting fetch...")
        do {
            // Try to fetch from the API first
            logger.info("🌐 Attempting to fetch product from API...")
            let product = try await apiService.getProductByCode(codigo: code)
            logger.info("✅ API fetch successful for code: \(code)")
            
            // If successful, save to local cache
            logger.info("💾 Saving product to local cache...")
            coreDataStack.saveProduct(product)
            logger.info("👍 Product saved to cache.")
            
            return (product, .api)
        } catch {
            logger.warning("⚠️ API fetch failed with error: \(error.localizedDescription). Trying local cache...")
            
            // If API fails, try to fetch from local cache
            if let productEntity = coreDataStack.fetchProduct(byCode: code) {
                logger.info("✅ Found product in local cache for code: \(code)")
                let product = Product(from: productEntity)
                return (product, .local)
            } else {
                // If not found in cache either, rethrow the original error
                logger.error("❌ Product not found in local cache for code: \(code). Rethrowing API error.")
                throw error
            }
        }
    }
}
