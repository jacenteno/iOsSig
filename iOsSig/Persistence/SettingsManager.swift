
import Foundation
import Combine

// Gestiona el guardado y la carga de configuraciones usando UserDefaults.
// Es un ObservableObject para que la UI pueda reaccionar a sus cambios.
class SettingsManager: ObservableObject {
    static let shared = SettingsManager() // Singleton para acceso global

    private let defaults = UserDefaults.standard

    // Claves para UserDefaults
    private enum Keys {
        static let productApiUrl = "productApiUrl"
        static let clientApiUrl = "clientApiUrl"
        static let citymallApiUrl = "citymallApiUrl"
        static let citymallFronteraApiUrl = "citymallFronteraApiUrl"
        
        static let useOldApi = "useOldApi"
        static let desplegarVentasApiOld="desplegarVentasApiOld"
        static let desplegarComprasApiOld="desplegarComprasApiOld"
        
        static let companyCode = "companyCode"
        static let companyName = "companyName"
        static let warehouseCode = "warehouseCode"
     
        static let precioCode = "precioCode"
        static let operadorCode = "operadorCode"
        static let userRole = "userRole"
        static let printerConnectionType = "printerConnectionType"
        static let printerIpAddress = "printerIpAddress"
        static let printerPort = "printerPort"
        static let printerMacAddress = "printerMacAddress"
        static let isActivated = "isActivated"
    }

    // @Published notifica a la UI de SwiftUI cuando un valor cambia
    @Published var productApiUrl: String {
        didSet { defaults.set(productApiUrl, forKey: Keys.productApiUrl) }
    }
    @Published var clientApiUrl: String {
        didSet { defaults.set(clientApiUrl, forKey: Keys.clientApiUrl) }
    }
    @Published var citymallApiUrl: String {
        didSet { defaults.set(citymallApiUrl, forKey: Keys.citymallApiUrl) }
    }
    @Published var citymallFronteraApiUrl: String {
        didSet { defaults.set(citymallFronteraApiUrl, forKey: Keys.citymallFronteraApiUrl) }
    }
    @Published var useOldApi: Bool {
        didSet { defaults.set(useOldApi, forKey: Keys.useOldApi) }
    }
    @Published var desplegarVentasApiOld: Bool {
        didSet { defaults.set(desplegarVentasApiOld, forKey: Keys.desplegarVentasApiOld) }
    }
    @Published var desplegarComprasApiOld: Bool {
        didSet { defaults.set(desplegarComprasApiOld, forKey: Keys.desplegarComprasApiOld) }
    }
    @Published var companyCode: Int {
        didSet { defaults.set(companyCode, forKey: Keys.companyCode) }
    }
    @Published var companyName: String {
        didSet { defaults.set(companyName, forKey: Keys.companyName) }
    }
    @Published var warehouseCode: String {
        didSet { defaults.set(warehouseCode, forKey: Keys.warehouseCode) }
    }
    @Published var precioCode: Int {
        didSet { defaults.set(precioCode, forKey: Keys.precioCode) }
    }
    @Published var operadorCode: Int {
        didSet { defaults.set(operadorCode, forKey: Keys.operadorCode) }
    }
    @Published var userRole: AppUserRole { // Changed type to AppUserRole
        didSet { defaults.set(userRole.rawValue, forKey: Keys.userRole) }
    }
    @Published var isActivated: Bool {
        didSet { defaults.set(isActivated, forKey: Keys.isActivated) }
    }

    // Configuración de la impresora
    enum PrinterConnectionType: String, CaseIterable, Codable {
        case none = "None"
        case wifi = "WIFI"
        case bluetooth = "Bluetooth"
    }

    @Published var printerConnectionType: PrinterConnectionType {
        didSet { defaults.set(printerConnectionType.rawValue, forKey: Keys.printerConnectionType) }
    }
    @Published var printerIpAddress: String {
        didSet { defaults.set(printerIpAddress, forKey: Keys.printerIpAddress) }
    }
    @Published var printerPort: String {
        didSet { defaults.set(printerPort, forKey: Keys.printerPort) }
    }
    @Published var printerMacAddress: String {
        didSet { defaults.set(printerMacAddress, forKey: Keys.printerMacAddress) }
    }

    private init() {
        // Cargar valores guardados o usar valores por defecto
        self.productApiUrl = defaults.string(forKey: Keys.productApiUrl) ?? "http://192.168.1.13:8000/"
        self.clientApiUrl = defaults.string(forKey: Keys.clientApiUrl) ?? "http://192.168.1.13:8001/"
        self.citymallApiUrl = defaults.string(forKey: Keys.citymallApiUrl) ?? "http://10.10.10.1:3000/"
        self.citymallFronteraApiUrl = defaults.string(forKey: Keys.citymallFronteraApiUrl) ?? "http://10.10.10.1:3001/"
        self.useOldApi = defaults.bool(forKey: Keys.useOldApi)
        self.desplegarVentasApiOld = defaults.bool(forKey: Keys.desplegarVentasApiOld)
        self.desplegarComprasApiOld = defaults.bool(forKey: Keys.desplegarComprasApiOld)
        
        self.companyCode = defaults.object(forKey: Keys.companyCode) as? Int ?? 6
        self.companyName = defaults.string(forKey: Keys.companyName) ?? "CitMall David"
        self.warehouseCode = defaults.string(forKey: Keys.warehouseCode) ?? "03"
        self.precioCode = defaults.object(forKey: Keys.precioCode) as? Int ?? 1
        self.operadorCode = defaults.object(forKey: Keys.operadorCode) as? Int ?? 1
        self.userRole = AppUserRole(rawValue: defaults.string(forKey: Keys.userRole) ?? AppUserRole.ROL_0.rawValue) ?? .ROL_0 // Updated to use AppUserRole
        self.isActivated = defaults.bool(forKey: Keys.isActivated)

        self.printerConnectionType = PrinterConnectionType(rawValue: defaults.string(forKey: Keys.printerConnectionType) ?? "None") ?? .none
        self.printerIpAddress = defaults.string(forKey: Keys.printerIpAddress) ?? "192.168.1.100"
        self.printerPort = defaults.string(forKey: Keys.printerPort) ?? "9100"
        self.printerMacAddress = defaults.string(forKey: Keys.printerMacAddress) ?? "00:11:22:33:44:55"
    }
    
    // Función para reiniciar la app (simulado)
    // En una app real, probablemente forzarías un re-renderizado del view root.
    func restartApp() {
        // Esto es un truco común: cambia una propiedad raíz para forzar a SwiftUI a redibujar.
        // Por ejemplo, podrías cambiar el ID de la vista principal en SigMpApp.swift
        print("Configuración guardada. La app se actualizará.")
    }
}
