import Combine
import Foundation

@MainActor
class CreaProductoViewModel: ObservableObject {
    @Published var departamentos: [Departamento] = []
    @Published var departamentoSeleccionado: Int? 
    @Published var codproducto: String = ""
    @Published var desproducto: String = ""
    @Published var preciodeventa: String = ""
    @Published var referencia: String = ""
    @Published var codigobarra: String = ""
    @Published var selectedTaxOption: String = "Exento"
    let taxOptions = ["Exento", "Gravado"]

    @Published var isLoading = false
    @Published var isFetchingDepartments = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let apiService: APIService
    private var settings: SettingsManager

    init(apiService: APIService = APIService(), settings: SettingsManager = .shared) {
        self.apiService = apiService
        self.settings = settings
    }

    func fetchDepartamentos() {
        print("CreaProductoViewModel: fetchDepartamentos() called")
        isFetchingDepartments = true
        Task {
            do {
                print("CreaProductoViewModel: Starting API call for departments...")
                let response = try await apiService.getDepartamentos()
                self.departamentos = response.results
                print("CreaProductoViewModel: Received \(response.results.count) departments.")
                if let firstDept = response.results.first {
                    self.departamentoSeleccionado = firstDept.coddepartamento
                    print("CreaProductoViewModel: Selected first department: \(firstDept.nomdepto)")
                }
            } catch {
                errorMessage = "Error al cargar departamentos: \(error.localizedDescription)"
                print("CreaProductoViewModel: Error fetching departments: \(error.localizedDescription)")
            }
            isFetchingDepartments = false
        }
    }

    func crearProducto() {
        guard validateFields() else { return }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        Task {
            do {
                // 1. Check if product exists
                do {
                    _ = try await apiService.getProductByCode(codigo: codproducto)
                    // If it succeeds, product exists
                    errorMessage = "El código de producto \(codproducto) ya existe."
                    isLoading = false
                    return
                } catch let error as APIError {
                    if error.isNotFoundError {
                        // This is what we want, product does not exist
                    } else {
                        // Any other error is unexpected
                        throw error
                    }
                }

                // 2. Prepare product for creation
                guard let precioDouble = Double(preciodeventa) else {
                    errorMessage = "El precio debe ser un número válido."
                    isLoading = false
                    return
                }

                let gravadoExecto = selectedTaxOption == "Exento" ? "E" : "G"
                let prcImpuestoVenta = selectedTaxOption == "Exento" ? 0.0 : 7.0 // Asumiendo 7.0% como en el ejemplo de Kotlin

                let listaDePrecio = ListaDePrecioParaCrear(
                    codGrPrecio: 6, // Valor por defecto como en el ejemplo de Kotlin
                    codBodega: settings.warehouseCode,
                    precioDeVenta: precioDouble,
                    codComp: settings.companyCode
                )

                let nuevoProducto = ProductoParaCrear(
                    detalle: desproducto,
                    codBodega: settings.warehouseCode,
                    codProducto: codproducto,
                    codFamilia: nil, // No presente en el form
                    codClase: nil, // No presente en el form
                    ultCosto: nil, // No presente en el form
                    existencias: 0, // Valor por defecto
                    codigoBarra: codigobarra,
                    costoFob: nil, // No presente en el form
                    desProducto: desproducto,
                    referencia: codigobarra,
                    codDep: departamentoSeleccionado,
                    prodPesado: nil, // No presente en el form
                    codCompania: settings.companyCode,
                    listasDePrecio: [listaDePrecio],
                    gravadoexecto: gravadoExecto,
                    preciodeventa: precioDouble,
                    prcimpuestoventa: prcImpuestoVenta,
                    codgrprecio: 6 // Valor por defecto como en el ejemplo de Kotlin
                )

                // 3. Log and Create product
                print("CreaProductoViewModel: Intentando crear producto con el siguiente objeto:")
                dump(nuevoProducto)

                _ = try await apiService.createProducto(producto: nuevoProducto)

                successMessage = "Producto creado exitosamente."
                isLoading = false
                
            } catch {
                errorMessage = "Error al crear el producto: \(error.localizedDescription)"
                print("CreaProductoViewModel: Error al crear producto: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }

    private func validateFields() -> Bool {
        if codproducto.isEmpty || desproducto.isEmpty || preciodeventa.isEmpty || departamentoSeleccionado == nil {
            errorMessage = "Por favor, complete todos los campos obligatorios."
            return false
        }
        return true
    }
}
