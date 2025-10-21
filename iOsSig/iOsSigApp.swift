
import SwiftUI

@main
struct iOsSigApp: App {
    // Carga una instancia del SettingsManager y la mantiene viva durante el ciclo de vida de la app.
    @StateObject private var settings = SettingsManager.shared

    var body: some Scene {
        WindowGroup {
            // Comprueba si la app está activada, similar a la lógica de MainActivity.kt
           // if !settings.isActivated {
            //    ActivationView()
             //       .environmentObject(settings)
            //} else {
                ContentView()
                    .environmentObject(settings)
           // }
        }
    }
}

// Una vista simple para la activación
struct ActivationView: View {
    @EnvironmentObject var settings: SettingsManager
    @State private var requestCode: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Activación Requerida")
                .font(.largeTitle)
            
            Text("Por favor, ingrese su código de activación.")
            
            TextField("Código de Activación", text: $requestCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Activar") {
                // Aquí iría tu lógica de validación del código de activación.
                // Por ahora, cualquier código la activará para fines de demostración.
                if !requestCode.isEmpty {
                    settings.isActivated = true
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

