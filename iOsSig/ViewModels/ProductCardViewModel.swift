import Foundation
import Combine
import os.log // Import os.log for logging

@MainActor
class ProductCardViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var showDetails = false
    @Published var showTabContent = true

    @Published var venta: Venta? = nil
    @Published var citymallProd: Resultado? = nil // This will now store the raw Resultado from APIServiceCMD
    @Published var cmdProductDetails: ProductDetails? // New: Stores processed details from APIServiceCMD

    private let apiService: APIService
    private let apiServiceCMD: APIServiceCMD // New: Instance for APIServiceCMD
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "ProductCardViewModel") // New: Logger

    private var fetchingVentas = false
    private var fetchingCompras = false
    private var fetchingCMDDetails = false // New: Flag for fetching CMD details

    init(apiService: APIService = APIService(), apiServiceCMD: APIServiceCMD = APIServiceCMD(session: .shared)) { // Modified init
        self.apiService = apiService
        self.apiServiceCMD = apiServiceCMD
        logger.info("✨ ProductCardViewModel inicializado")
    }

    // New function to load product details from APIServiceCMD with fallback to APIService
    func loadProductDetails(for product: Product) {
        guard let productCode = product.codproducto?.trimmingCharacters(in: .whitespacesAndNewlines), !productCode.isEmpty else {
            logger.warning("⚠️ Código de producto vacío, no se pueden cargar detalles.")
            return
        }

        if fetchingCMDDetails {
            logger.info("⏳ Ya se están cargando los detalles del producto CMD, omitiendo.")
            return
        }

        fetchingCMDDetails = true
        Task {
            defer { self.fetchingCMDDetails = false }
            logger.info("🌐 Intentando obtener detalles del producto de APIServiceCMD para: \(productCode)")
            do {
                let cmdDetails = try await apiServiceCMD.getProductDetails(productCode: productCode)
                if cmdDetails.found {
                    self.cmdProductDetails = cmdDetails
                    logger.info("✅ Detalles del producto obtenidos de APIServiceCMD.")
                } else {
                    logger.info("ℹ️ APIServiceCMD no encontró el producto o los detalles. Intentando con APIService (fallback).")
                    // Fallback to APIService
                    let fallbackProduct = try await apiService.getProductByCode(codigo: productCode)
                    self.cmdProductDetails = ProductDetails(
                        costo: fallbackProduct.ultcosto,
                        costoFob: fallbackProduct.costofob,
                        existencia: fallbackProduct.existencias != nil ? Int(fallbackProduct.existencias!) : nil,
                        comprasRealizadas: nil, // APIService.getProductByCode does not provide purchase history
                        found: true
                    )
                    logger.info("✅ Detalles del producto obtenidos de APIService (fallback). ")
                }
            } catch {
                logger.error("❌ Error al cargar detalles del producto (CMD o fallback): \(error.localizedDescription)")
                // If both fail, we can set cmdProductDetails to nil or handle the error appropriately
                self.cmdProductDetails = nil
            }
        }
    }

    func fetchVentas(for product: Product, completion: @escaping (Bool) -> Void) {
        guard let codproducto = product.codproducto?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            completion(false)
            return
        }

        if self.venta != nil || fetchingVentas {
            completion(true)
            return
        }

        fetchingVentas = true
        Task {
            defer { self.fetchingVentas = false }
            let ventaResult = try? await apiService.getVentasMensuales(codproducto: codproducto)

            self.venta = ventaResult
            completion(self.venta != nil)
        }
    }

    func fetchCompras(for product: Product, completion: @escaping (Bool) -> Void) {
        // BUG FIX: Changed from product.codigobarra to product.codproducto to use the correct identifier.
        guard let productCode = product.codproducto?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            logger.warning("⚠️ fetchCompras falló: codproducto es nulo o vacío.")
            completion(false)
            return
        }

        if self.citymallProd != nil || fetchingCompras {
            completion(true)
            return
        }

        fetchingCompras = true
        Task {
            defer { self.fetchingCompras = false }
            logger.info("🌐 Llamando a APIServiceCMD (a través de APIService) para obtener compras para: \(productCode)")
            do {
                // APIService.getCitymallProduct returns Resultado, which contains 'compras'
                let rawResultado = try await apiService.getCitymallProduct(barCode: productCode)
                self.citymallProd = rawResultado // Store the raw Resultado
                completion(true)
            } catch {
                logger.error("❌ Error al obtener compras de APIServiceCMD: \(error.localizedDescription)")
                self.citymallProd = nil
                completion(false)
            }
        }
    }
}