
import SwiftUI

struct SettingsView: View {
    // @EnvironmentObject nos permite acceder al SettingsManager que pasaremos desde la vista principal.
    @EnvironmentObject var settings: SettingsManager
    
    // Estado para controlar la autenticación y la UI
    @State private var passwordInput: String = ""
    @State private var isMasterAuthenticated: Bool = false
    @State private var errorMessage: String? = nil
    
    // Para cerrar la vista modal
    @Environment(\.presentationMode) var presentationMode

    private let masterPassword = "120525"

    var body: some View {
        NavigationView {
            VStack {
                if !isMasterAuthenticated {
                    authenticationView
                } else {
                    settingsForm
                }
            }
            .navigationTitle("Configuración")
            .navigationBarItems(leading: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    // Vista para la entrada de la contraseña
    private var authenticationView: some View {
        VStack(spacing: 20) {
            Text("Ingrese la clave maestra para acceder.")
            SecureField("Clave", text: $passwordInput)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("Aceptar") {
                if passwordInput == masterPassword {
                    withAnimation {
                        isMasterAuthenticated = true
                        errorMessage = nil
                    }
                } else {
                    errorMessage = "Clave incorrecta."
                }
                passwordInput = ""
            }
            .padding()
        }
        .padding()
    }

    // Formulario principal de configuración
    private var settingsForm: some View {
        Form {
            Section(header: Text("Configuración de APIs")) {
                HStack {
                    Text("URL de Productos")
                    Spacer()
                    TextField("", text: $settings.productApiUrl).keyboardType(.URL)
                }
                HStack {
                    Text("URL de Clientes")
                    Spacer()
                    TextField("", text: $settings.clientApiUrl).keyboardType(.URL)
                }
                HStack {
                    Text("URL Citymall DAVID")
                    Spacer()
                    TextField("", text: $settings.citymallApiUrl).keyboardType(.URL)
                }
                HStack {
                    Text("URL Citymall FRONTERA")
                    Spacer()
                    TextField("", text: $settings.citymallFronteraApiUrl).keyboardType(.URL)
                }
                Toggle("Usar API Anterior", isOn: $settings.useOldApi)
            }
            
            Section(header: Text("Configuración de Tienda")) {
                HStack {
                    Text("Cód. Compañía")
                    Spacer()
                    TextField("", value: $settings.companyCode, formatter: NumberFormatter()).keyboardType(.numberPad)
                }
                TextField("Cód. Bodega", text: $settings.warehouseCode)
                HStack {
                    Text("Nivel Precio")
                    Spacer()
                    TextField("", value: $settings.precioCode, formatter: NumberFormatter()).keyboardType(.numberPad)
                }
                HStack {
                    Text("Nº Operador")
                    Spacer()
                    TextField("", value: $settings.operadorCode, formatter: NumberFormatter()).keyboardType(.numberPad)
                }
            }
            
            Section(header: Text("Configuración de Impresora")) {
                Picker("Tipo de Conexión", selection: $settings.printerConnectionType) {
                    ForEach(SettingsManager.PrinterConnectionType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                if settings.printerConnectionType == .wifi {
                    TextField("Dirección IP", text: $settings.printerIpAddress).keyboardType(.URL)
                    TextField("Puerto", text: $settings.printerPort).keyboardType(.numberPad)
                }
                if settings.printerConnectionType == .bluetooth {
                    TextField("Dirección MAC", text: $settings.printerMacAddress)
                }
            }
            
            Section(header: Text("Rol del Dispositivo")) {
                Picker("Rol", selection: $settings.userRole) {
                    ForEach(UserRole.allCases, id: \.self) {
                        Text($0.rawValue.capitalized)
                    }
                }
            }
            
            // El botón de guardar está implícito, los cambios se guardan automáticamente
            // gracias a @Published y didSet en SettingsManager.
            // Podríamos añadir un botón explícito si se prefiere reiniciar la app.
            Section {
                Button("Guardar y Reiniciar") {
                    // Aquí se podría llamar a una función que reinicie el estado de la app
                    settings.restartApp()
                    presentationMode.wrappedValue.dismiss() // Cierra la vista de configuración
                }
                .foregroundColor(.blue)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsManager.shared)
    }
}
