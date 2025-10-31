
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

    private let masterPassword = Secrets.getMasterPassword()

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
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 50))
                .foregroundColor(.accentColor)
                .padding(.bottom)
            
            Text("Acceso Restringido")
                .font(.title2)
                .fontWeight(.bold)

            Text("Ingrese la clave maestra para continuar.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            SecureField("Clave", text: $passwordInput)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .frame(maxWidth: 280)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            Button(action: {
                if passwordInput == masterPassword {
                    withAnimation {
                        isMasterAuthenticated = true
                        errorMessage = nil
                    }
                } else {
                    errorMessage = "Clave incorrecta."
                }
                passwordInput = ""
            }) {
                HStack {
                    Spacer()
                    Text("Aceptar")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .tint(.accentColor)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: 280)
            .padding(.top)
        }
        .padding()
    }

    // Formulario principal de configuración
    private var settingsForm: some View {
        Form {
            Section(header: Text("Configuración de APIs")) {
                Label {
                    TextField("URL de Productos", text: $settings.productApiUrl)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                } icon: {
                    Image(systemName: "shippingbox.circle.fill")
                }

                Label {
                    TextField("URL de Clientes", text: $settings.clientApiUrl)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                } icon: {
                    Image(systemName: "person.2.circle.fill")
                }

                Label {
                    TextField("URL Citymall DAVID", text: $settings.citymallApiUrl)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                } icon: {
                    Image(systemName: "d.circle.fill")
                }

                Label {
                    TextField("URL Citymall FRONTERA", text: $settings.citymallFronteraApiUrl)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                } icon: {
                    Image(systemName: "f.circle.fill")
                }

                Toggle(isOn: $settings.useOldApi) {
                    Label("Usar API Old", systemImage: "arrow.left.arrow.right")
                }
                
                Toggle(isOn: $settings.desplegarVentasApiOld) {
                    Label("Mostrar Ventas de Api OLD", systemImage: "arrow.left.arrow.right")
                }
                
                Toggle(isOn: $settings.desplegarComprasApiOld) {
                    Label("Mostrar Compras de Api OLD", systemImage: "arrow.left.arrow.right")
                }
                
                

            }
            
            Section(header: Text("Configuración de Tienda")) {
                Label {
                    TextField("Compañía", value: $settings.companyCode, formatter: NumberFormatter())
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                } icon: {
                    Image(systemName: "building.2.fill")
                }
                
                Label {
                    TextField("Nombre de Tienda", text: $settings.companyName)
                        .multilineTextAlignment(.trailing)
                        .autocapitalization(.allCharacters)
                } icon: {
                    Image(systemName: "chart.bar.fill")
                }

                Label {
                    TextField("Bodega", text: $settings.warehouseCode)
                        .multilineTextAlignment(.trailing)
                        .autocapitalization(.allCharacters)
                } icon: {
                    Image(systemName: "archivebox.circle.fill")
                }

                Label {
                    TextField("Precio", value: $settings.precioCode, formatter: NumberFormatter())
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                } icon: {
                    Image(systemName: "dollarsign.circle.fill")
                }

                Label {
                    TextField("Operador", value: $settings.operadorCode, formatter: NumberFormatter())
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                } icon: {
                    Image(systemName: "person.badge.key.fill")
                }
            }
            
            Section(header: Text("Configuración de Impresora")) {
                Picker(selection: $settings.printerConnectionType) {
                    ForEach(SettingsManager.PrinterConnectionType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                } label: {
                    Label("Tipo de Conexión", systemImage: "printer.fill")
                }

                if settings.printerConnectionType == .wifi {
                    Label {
                        TextField("192.168.1.100", text: $settings.printerIpAddress)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    } icon: {
                        Image(systemName: "wifi")
                    }
                    Label {
                        TextField("9100", text: $settings.printerPort)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    } icon: {
                        Image(systemName: "point.3.connected.trianglepath.dotted")
                    }
                }
                if settings.printerConnectionType == .bluetooth {
                    Label {
                        TextField("00:11:22:33:44:55", text: $settings.printerMacAddress)
                            .multilineTextAlignment(.trailing)
                            .autocapitalization(.allCharacters)
                    } icon: {
                        Image(systemName: "b.circle.fill")
                    }
                }
            }
            
            Section(header: Text("Rol del Dispositivo")) {
                Picker(selection: $settings.userRole) {
                    ForEach(AppUserRole.allCases, id: \.self) {
                        Text($0.rawValue.capitalized)
                    }
                } label: {
                    Label("Rol", systemImage: "person.text.rectangle.fill")
                }
            }

            Section {
                Button(action: {
                    settings.restartApp()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Spacer()
                        Text("Guardar")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .tint(.accentColor)
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
