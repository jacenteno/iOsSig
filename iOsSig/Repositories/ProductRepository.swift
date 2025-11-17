import Combine
import CoreData
import Foundation
import os.log

enum DataSource {
  case api
  case local
}

class ProductRepository: ObservableObject {
  static let shared = ProductRepository()

  private let apiService: APIService
  private let coreDataStack: CoreDataStack
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "ProductRepository")

  @Published var totalProductsCount = 0

  init(apiService: APIService = APIService.shared, coreDataStack: CoreDataStack = .shared) {
    self.apiService = apiService
    self.coreDataStack = coreDataStack
  }

  func getProduct(byCode code: String) async throws -> (product: Product, source: DataSource) {
    logger.info("🚀 getProduct(byCode: \(code)) - Starting fetch...")
    do {
      let product = try await apiService.getProductByCode(codigo: code)
      logger.info("✅ API fetch successful for code: \(code)")
      coreDataStack.saveProduct(product)
      logger.info("👍 Product saved to cache.")
      return (product, .api)
    } catch {
      logger.warning("⚠️ API fetch failed: \(error.localizedDescription). Trying local cache...")
      if let productEntity = coreDataStack.fetchProduct(byCode: code) {
        logger.info("✅ Found product in local cache for code: \(code)")
        let product = Product(entity: productEntity)
        return (product, .local)
      } else {
        logger.error("❌ Product not found in local cache for code: \(code). Rethrowing error.")
        throw error
      }
    }
  }

  func saveProducts(_ products: [Product]) async {
    logger.info("💾 Saving batch of \(products.count) products to Core Data.")
    let context = coreDataStack.persistentContainer.newBackgroundContext()
    await context.perform {
      for product in products {
        let entity =
          self.coreDataStack.fetchProduct(byCode: product.codproducto ?? "", in: context)
          ?? ProductEntity(context: context)
        entity.codproducto = product.codproducto?.trimmingCharacters(in: .whitespacesAndNewlines)
        entity.desproducto = product.desproducto
        entity.codigobarra = product.codigobarra?.trimmingCharacters(in: .whitespacesAndNewlines)
        entity.preciodeventa = product.preciodeventa ?? 0.0
        entity.existencias = product.existencias ?? 0.0
        entity.ultcosto = product.ultcosto ?? 0.0
        entity.referencia = product.referencia?.trimmingCharacters(in: .whitespacesAndNewlines)
        entity.nombre_departamento = product.nombre_departamento
        entity.codbodega = product.codbodega?.trimmingCharacters(in: .whitespacesAndNewlines)
      }

      do {
        try context.save()
        self.logger.info("✅ Successfully saved batch of products.")
      } catch {
        self.logger.error("❌ Error saving batch of products: \(error.localizedDescription)")
      }
    }
  }

  func saveProduct(_ product: Product) async {
    logger.info("💾 Saving single product to Core Data: \(product.codproducto ?? "N/A")")
    let context = coreDataStack.persistentContainer.newBackgroundContext()
    await context.perform {
      self.coreDataStack.saveProduct(product, in: context)
      do {
        try context.save()
      } catch {
        self.logger.error("❌ Error saving single product: \(error.localizedDescription)")
      }
    }
  }

  func deleteProducts(byDepartment departmentName: String) async throws {
    logger.info("🗑️ Deleting products from department: \(departmentName)")
    let context = coreDataStack.persistentContainer.newBackgroundContext()
    await context.perform {
      let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ProductEntity.fetchRequest()
      fetchRequest.predicate = NSPredicate(format: "nombre_departamento == %@", departmentName)

      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

      do {
        try context.execute(deleteRequest)
        try context.save()
        self.logger.info("✅ Successfully deleted products from department: \(departmentName)")
      } catch {
        self.logger.error(
          "❌ Error deleting products from department \(departmentName): \(error.localizedDescription)"
        )
        // We don't rethrow here as we want the sync to continue if possible
      }
    }
  }

  @MainActor
  func fetchTotalProductsCount() async {
    logger.info("🔍 Fetching total products count from Core Data.")
    let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()

    do {
      let count = try coreDataStack.viewContext.count(for: request)
      self.totalProductsCount = count
      logger.info("📊 Total products count: \(count)")
    } catch {
      logger.error("❌ Error fetching total products count: \(error.localizedDescription)")
    }
  }

  func fetchLocalProducts(filter: String) async -> [Product] {
    logger.info("🔍 Fetching local products with filter: \(filter)")
    let context = coreDataStack.persistentContainer.newBackgroundContext()
    return await context.perform {
      let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()

      if !filter.isEmpty {
        let descriptionPredicate = NSPredicate(format: "desproducto CONTAINS[c] %@", filter)
        let codePredicate = NSPredicate(format: "codproducto CONTAINS[c] %@", filter)
        let barcodePredicate = NSPredicate(format: "codigobarra CONTAINS[c] %@", filter)
        let refPredicate = NSPredicate(format: "referencia CONTAINS[c] %@", filter)
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
          descriptionPredicate, codePredicate, barcodePredicate, refPredicate,
        ])
      }

      do {
        let entities = try context.fetch(request)
        self.logger.info("✅ Found \(entities.count) local products.")
        return entities.map { Product(entity: $0) }
      } catch {
        self.logger.error("❌ Error fetching local products: \(error.localizedDescription)")
        return []
      }
    }
  }
}
