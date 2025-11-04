


import SwiftUI



struct SettingsView: View {

    @EnvironmentObject var settings: SettingsManager

    

    @State private var passwordInput: String = ""

    @State private var isMasterAuthenticated: Bool = false

    @State private var errorMessage: String? = nil

    

    // State to hold temporary edits

    @State private var tempSettings: TempSettings?

    

    @Environment(\.presentationMode) var presentationMode



    private let masterPassword = Secrets.getMasterPassword()



        var body: some View {



            ZStack(alignment: .bottomTrailing) {



                NavigationView {



                    VStack {



                        if let _ = tempSettings {



                            settingsForm



                        } else {



                            ProgressView()



                                .onAppear(perform: loadSettings)



                        }



                    }



                    .navigationTitle("Configuración")



                    .navigationBarItems(leading: Button("Cerrar") {



                        presentationMode.wrappedValue.dismiss()



                    })



                }



    



                // Floating Save Button



                Button(action: {



                    if let temp = tempSettings {



                        settings.productApiUrl = temp.productApiUrl



                        settings.clientApiUrl = temp.clientApiUrl



                        settings.citymallApiUrl = temp.citymallApiUrl



                        settings.citymallFronteraApiUrl = temp.citymallFronteraApiUrl



                        settings.useOldApi = temp.useOldApi



                        settings.desplegarVentasApiOld = temp.desplegarVentasApiOld



                        settings.desplegarComprasApiOld = temp.desplegarComprasApiOld



                        settings.companyCode = temp.companyCode



                        settings.companyName = temp.companyName



                        settings.warehouseCode = temp.warehouseCode



                        settings.precioCode = temp.precioCode



                        settings.operadorCode = temp.operadorCode



                        settings.userRole = temp.userRole



                        settings.printerConnectionType = temp.printerConnectionType



                        settings.printerIpAddress = temp.printerIpAddress



                        settings.printerPort = temp.printerPort



                        settings.printerMacAddress = temp.printerMacAddress



                        settings.appColorScheme = temp.appColorScheme



                        settings.accentColor = temp.accentColor.toHex() ?? "#FF0000"



                    }



                    settings.restartApp()



                    presentationMode.wrappedValue.dismiss()



                }) {



                    Label("Guardar", systemImage: "checkmark.circle.fill")



                        .font(.headline)



                        .padding(.vertical, 12)



                        .padding(.horizontal, 20)



                        .background(Color.accentColor)



                        .foregroundColor(.white)



                        .cornerRadius(30)



                        .shadow(radius: 10)



                }



                .padding(.trailing, 20)



                .padding(.bottom, 20)



            }



        }



    private func loadSettings() {

        tempSettings = TempSettings(

            productApiUrl: settings.productApiUrl,

            clientApiUrl: settings.clientApiUrl,

            citymallApiUrl: settings.citymallApiUrl,

            citymallFronteraApiUrl: settings.citymallFronteraApiUrl,

            useOldApi: settings.useOldApi,

            desplegarVentasApiOld: settings.desplegarVentasApiOld,

            desplegarComprasApiOld: settings.desplegarComprasApiOld,

            companyCode: settings.companyCode,

            companyName: settings.companyName,

            warehouseCode: settings.warehouseCode,

            precioCode: settings.precioCode,

            operadorCode: settings.operadorCode,

            userRole: settings.userRole,

            printerConnectionType: settings.printerConnectionType,

            printerIpAddress: settings.printerIpAddress,

            printerPort: settings.printerPort,

            printerMacAddress: settings.printerMacAddress,

            appColorScheme: settings.appColorScheme,

            accentColor: Color(hex: settings.accentColor) ?? .accentColor

        )

    }



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



    private var settingsForm: some View {

        Form {
            Section(header: Text("Apariencia")) {
                Picker("Esquema de Color", selection: Binding($tempSettings)!.appColorScheme) {
                    ForEach(SettingsManager.AppColorScheme.allCases) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)

                ColorPicker("Color de Acento", selection: Binding($tempSettings)!.accentColor)
            }

            Section(header: Text("Configuración de APIs")) {

                Label {

                    TextField("URL de Productos", text: Binding($tempSettings)!.productApiUrl)

                        .multilineTextAlignment(.trailing)

                        .keyboardType(.URL)

                        .autocapitalization(.none)

                } icon: {

                    Image(systemName: "shippingbox.circle.fill")

                }



                Label {

                    TextField("URL de Clientes", text: Binding($tempSettings)!.clientApiUrl)

                        .multilineTextAlignment(.trailing)

                        .keyboardType(.URL)

                        .autocapitalization(.none)

                } icon: {

                    Image(systemName: "person.2.circle.fill")

                }



                Label {

                    TextField("URL Citymall DAVID", text: Binding($tempSettings)!.citymallApiUrl)

                        .multilineTextAlignment(.trailing)

                        .keyboardType(.URL)

                        .autocapitalization(.none)

                } icon: {

                    Image(systemName: "d.circle.fill")

                }



                Label {

                    TextField("URL Citymall FRONTERA", text: Binding($tempSettings)!.citymallFronteraApiUrl)

                        .multilineTextAlignment(.trailing)

                        .keyboardType(.URL)

                        .autocapitalization(.none)

                } icon: {

                    Image(systemName: "f.circle.fill")

                }



                Toggle(isOn: Binding($tempSettings)!.useOldApi) {

                    Label("Usar API Old", systemImage: "arrow.left.arrow.right")

                }

                

                Toggle(isOn: Binding($tempSettings)!.desplegarVentasApiOld) {

                    Label("Mostrar Ventas de Api OLD", systemImage: "arrow.left.arrow.right")

                }

                

                Toggle(isOn: Binding($tempSettings)!.desplegarComprasApiOld) {

                    Label("Mostrar Compras de Api OLD", systemImage: "arrow.left.arrow.right")

                }

            }

            

            Section(header: Text("Configuración de Tienda")) {

                Label {

                    TextField("Compañía", value: Binding($tempSettings)!.companyCode, formatter: NumberFormatter())

                        .multilineTextAlignment(.trailing)

                        .keyboardType(.numberPad)

                } icon: {

                    Image(systemName: "building.2.fill")

                }

                

                Label {

                    TextField("Nombre de Tienda", text: Binding($tempSettings)!.companyName)

                        .multilineTextAlignment(.trailing)

                        .autocapitalization(.allCharacters)

                } icon: {

                    Image(systemName: "chart.bar.fill")

                }



                Label {

                    TextField("Bodega", text: Binding($tempSettings)!.warehouseCode)

                        .multilineTextAlignment(.trailing)

                        .autocapitalization(.allCharacters)

                } icon: {

                    Image(systemName: "archivebox.circle.fill")

                }



                Label {

                    TextField("Precio", value: Binding($tempSettings)!.precioCode, formatter: NumberFormatter())

                        .multilineTextAlignment(.trailing)

                        .keyboardType(.numberPad)

                } icon: {

                    Image(systemName: "dollarsign.circle.fill")

                }



                Label {

                    TextField("Operador", value: Binding($tempSettings)!.operadorCode, formatter: NumberFormatter())

                        .multilineTextAlignment(.trailing)

                        .keyboardType(.numberPad)

                } icon: {

                    Image(systemName: "person.badge.key.fill")

                }

            }

            

            Section(header: Text("Configuración de Impresora")) {

                Picker(selection: Binding($tempSettings)!.printerConnectionType) {

                    ForEach(SettingsManager.PrinterConnectionType.allCases, id: \.self) {

                        Text($0.rawValue)

                    }

                } label: {

                    Label("Tipo de Conexión", systemImage: "printer.fill")

                }



                if tempSettings?.printerConnectionType == .wifi {

                    Label {

                        TextField("192.168.1.100", text: Binding($tempSettings)!.printerIpAddress)

                            .multilineTextAlignment(.trailing)

                            .keyboardType(.URL)

                            .autocapitalization(.none)

                    } icon: {

                        Image(systemName: "wifi")

                    }

                    Label {

                        TextField("9100", text: Binding($tempSettings)!.printerPort)

                            .multilineTextAlignment(.trailing)

                            .keyboardType(.numberPad)

                    } icon: {

                        Image(systemName: "point.3.connected.trianglepath.dotted")

                    }

                }

                if tempSettings?.printerConnectionType == .bluetooth {

                    Label {

                        TextField("00:11:22:33:44:55", text: Binding($tempSettings)!.printerMacAddress)

                            .multilineTextAlignment(.trailing)

                            .autocapitalization(.allCharacters)

                    } icon: {

                        Image(systemName: "b.circle.fill")

                    }

                }

            }

            

            Section(header: Text("Rol del Dispositivo")) {

                Picker(selection: Binding($tempSettings)!.userRole) {

                    ForEach(AppUserRole.allCases, id: \.self) {

                        Text($0.rawValue.capitalized)

                    }

                } label: {

                    Label("Rol", systemImage: "person.text.rectangle.fill")

                }

            }



        }

    }

}



// A struct to hold the temporary settings

struct TempSettings {

    var productApiUrl: String

    var clientApiUrl: String

    var citymallApiUrl: String

    var citymallFronteraApiUrl: String

    var useOldApi: Bool

    var desplegarVentasApiOld: Bool

    var desplegarComprasApiOld: Bool

    var companyCode: Int

    var companyName: String

    var warehouseCode: String

    var precioCode: Int

    var operadorCode: Int

    var userRole: AppUserRole

    var printerConnectionType: SettingsManager.PrinterConnectionType

    var printerIpAddress: String

    var printerPort: String

    var printerMacAddress: String

    var appColorScheme: SettingsManager.AppColorScheme

    var accentColor: Color

}



struct SettingsView_Previews: PreviewProvider {

    static var previews: some View {

        SettingsView()

            .environmentObject(SettingsManager.shared)

    }

}


