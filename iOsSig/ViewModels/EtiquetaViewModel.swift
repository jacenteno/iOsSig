import Foundation
import Combine

@MainActor
class EtiquetaViewModel: ObservableObject {
    @Published var cantidad: String = "1"
    @Published var showAlert = false
    @Published var alertMessage = ""

    func printLabels(product: Product) {
        guard let cantidadInt = Int(cantidad), cantidadInt > 0 else {
            alertMessage = "La cantidad debe ser un número mayor que cero."
            showAlert = true
            return
        }

        // Placeholder for printing logic
        print("--- INICIANDO IMPRESIÓN DE ETIQUETAS ---")
        print("Producto: \(product.desproducto ?? "N/A")")
        print("Código: \(product.codproducto ?? "N/A")")
        print("Cantidad: \(cantidadInt)")
        print("--- AQUÍ VA LA LÓGICA PARA CONECTARSE A LA IMPRESORA (Wi-Fi o Bluetooth) Y ENVIAR LOS DATOS ---")
        // You would use the settings from SettingsManager to connect to the printer.
        // let settings = SettingsManager.shared
        // if settings.printerConnectionType == .wifi { ... }
        // if settings.printerConnectionType == .bluetooth { ... }
        print("--- FIN DE LA IMPRESIÓN ---")

        alertMessage = "Se han enviado a imprimir \(cantidadInt) etiqueta(s)."
        showAlert = true
    }
}
