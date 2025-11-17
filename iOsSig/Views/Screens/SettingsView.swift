import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var settings: SettingsManager
  @Environment(\.presentationMode) var presentationMode

  @State private var passwordInput: String = ""
  @State private var isMasterAuthenticated: Bool = false
  @State private var errorMessage: String? = nil

  @State private var tempSettings: TempSettings?

  private let masterPassword = Secrets.getMasterPassword()

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      NavigationView {
        Group {
          if tempSettings != nil {
            settingsForm
          } else {
            loadingView
          }
        }
        .navigationTitle("Configuración")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
              presentationMode.wrappedValue.dismiss()
            }) {
              Label("Cerrar", systemImage: "xmark.circle.fill")
                .foregroundColor(.secondary)
            }
          }
        }
      }
      .accentColor(tempSettings?.accentColor ?? Color(hex: settings.accentColor) ?? .accentColor)

      // Floating Save Button
      if tempSettings != nil {
        saveButton
      }
    }
    .onAppear(perform: loadSettings)
  }

  // MARK: - VIEWS

  private var loadingView: some View {
    VStack(spacing: 20) {
      ProgressView()
        .scaleEffect(1.5)
        .tint(Color(hex: settings.accentColor) ?? .accentColor)
      Text("Cargando configuración...")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
  }

  private var settingsForm: some View {
    ScrollView {
      VStack(spacing: 20) {
        // HEADER MODERNO
        settingsHeader

        // FORMULARIO CON ESTILO APPLE
        ModernFormCard {
          appearanceSection
          apiSection
          storeSection
          printerSection
          roleSection
          adminSection
        }
      }
      .padding()
    }
    .background(Color(.systemGroupedBackground))
  }

  private var settingsHeader: some View {
    VStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(
            LinearGradient(
              colors: [
                tempSettings?.accentColor ?? .accentColor,
                (tempSettings?.accentColor ?? .accentColor).opacity(0.6),
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 80, height: 80)

        Image(systemName: "gear.circle.fill")
          .font(.system(size: 50, weight: .bold))
          .foregroundColor(.white)
          .symbolRenderingMode(.hierarchical)
      }
      .shadow(
        color: (tempSettings?.accentColor ?? .accentColor).opacity(0.3), radius: 10, x: 0, y: 5)

      Text("Personaliza tu experiencia")
        .font(.system(size: 22, weight: .bold, design: .rounded))
        .foregroundColor(.primary)

      Text("Ajusta los valores de conexión y preferencias de tu tienda")
        .font(.system(size: 15, weight: .medium))
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 24)
        .fill(Color(.systemBackground))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
  }

  private var appearanceSection: some View {
    Section {
      Picker("Esquema de Color", selection: Binding($tempSettings)!.appColorScheme) {
        ForEach(SettingsManager.AppColorScheme.allCases) {
          Text($0.rawValue).tag($0)
        }
      }
      .pickerStyle(.segmented)

      ColorPicker("Color de Acento", selection: Binding($tempSettings)!.accentColor)

      let predefinedColors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .teal, .mint]
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(predefinedColors, id: \.self) { color in
            Circle()
              .fill(color)
              .frame(width: 32, height: 32)
              .overlay(
                Circle()
                  .stroke(Color.primary.opacity(0.2), lineWidth: 1)
              )
              .scaleEffect(tempSettings?.accentColor == color ? 1.2 : 1.0)
              .animation(.spring(response: 0.3), value: tempSettings?.accentColor)
              .onTapGesture {
                tempSettings?.accentColor = color
              }
          }
        }
        .padding(.vertical, 8)
      }
    } header: {
      Label("Apariencia", systemImage: "paintbrush.fill")
        .sectionHeader(color: tempSettings?.accentColor ?? .accentColor)
    }
  }

  private var apiSection: some View {
    Section {
      ModernTextField(
        icon: "shippingbox.circle.fill", title: "URL de Productos",
        text: Binding($tempSettings)!.productApiUrl, keyboard: .URL)
      ModernTextField(
        icon: "person.2.circle.fill", title: "URL de Clientes",
        text: Binding($tempSettings)!.clientApiUrl, keyboard: .URL)
      ModernTextField(
        icon: "d.circle.fill", title: "URL Citymall DAVID",
        text: Binding($tempSettings)!.citymallApiUrl, keyboard: .URL)
      ModernTextField(
        icon: "f.circle.fill", title: "URL Citymall FRONTERA",
        text: Binding($tempSettings)!.citymallFronteraApiUrl, keyboard: .URL)

      ModernToggle(
        icon: "arrow.left.arrow.right", title: "Usar API Old",
        isOn: Binding($tempSettings)!.useOldApi)
      ModernToggle(
        icon: "chart.line.uptrend.xyaxis", title: "Mostrar Ventas API OLD",
        isOn: Binding($tempSettings)!.desplegarVentasApiOld)
      ModernToggle(
        icon: "cart.fill", title: "Mostrar Compras API OLD",
        isOn: Binding($tempSettings)!.desplegarComprasApiOld)
    } header: {
      Label("Configuración de APIs", systemImage: "network.badge.shield.half.filled")
        .sectionHeader(color: tempSettings?.accentColor ?? .accentColor)
    }
  }

  private var storeSection: some View {
    Section {
      ModernTextField(
        icon: "building.2.fill",
        title: "Compañía",
        text: Binding(
          get: { String(tempSettings?.companyCode ?? 0) },
          set: { tempSettings?.companyCode = Int($0) ?? 0 }
        ),
        keyboard: .numberPad
      )

      ModernTextField(
        icon: "chart.bar.fill", title: "Nombre de Tienda",
        text: Binding($tempSettings)!.companyName, capitalization: .allCharacters)
      ModernTextField(
        icon: "archivebox.circle.fill", title: "Bodega",
        text: Binding($tempSettings)!.warehouseCode, capitalization: .allCharacters)
      ModernTextField(
        icon: "dollarsign.circle.fill",
        title: "Precio",
        text: Binding(
          get: { String(tempSettings?.precioCode ?? 0) },
          set: { tempSettings?.precioCode = Int($0) ?? 0 }
        ),
        keyboard: .numberPad
      )
      ModernTextField(
        icon: "person.badge.key.fill",
        title: "Operador",
        text: Binding(
          get: { String(tempSettings?.operadorCode ?? 0) },
          set: { tempSettings?.operadorCode = Int($0) ?? 0 }
        ),
        keyboard: .numberPad
      )
    } header: {
      Label("Configuración de Tienda", systemImage: "storefront.fill")
        .sectionHeader(color: tempSettings?.accentColor ?? .accentColor)
    }
  }

  private var printerSection: some View {
    Section {
      Picker(selection: Binding($tempSettings)!.printerConnectionType) {
        ForEach(SettingsManager.PrinterConnectionType.allCases, id: \.self) {
          Text($0.rawValue)
        }
      } label: {
        Label("Tipo de Conexión", systemImage: "printer.fill")
      }

      if tempSettings?.printerConnectionType == .wifi {
        ModernTextField(
          icon: "wifi", title: "IP Impresora", text: Binding($tempSettings)!.printerIpAddress,
          keyboard: .URL)
        ModernTextField(
          icon: "point.3.connected.trianglepath.dotted", title: "Puerto",
          text: Binding($tempSettings)!.printerPort, keyboard: .numberPad)
      }

      if tempSettings?.printerConnectionType == .bluetooth {
        ModernTextField(
          icon: "b.circle.fill", title: "MAC Address",
          text: Binding($tempSettings)!.printerMacAddress, capitalization: .allCharacters)
      }
    } header: {
      Label("Configuración de Impresora", systemImage: "printer.dotmatrix.fill")
        .sectionHeader(color: tempSettings?.accentColor ?? .accentColor)
    }
  }

  private var roleSection: some View {
    Section {
      Picker(selection: Binding($tempSettings)!.userRole) {
        ForEach(AppUserRole.allCases, id: \.self) {
          Text($0.rawValue.capitalized)
        }
      } label: {
        Label("Rol del Dispositivo", systemImage: "person.text.rectangle.fill")
      }
    } header: {
      Label("Rol del Dispositivo", systemImage: "person.badge.shield.checkmark.fill")
        .sectionHeader(color: tempSettings?.accentColor ?? .accentColor)
    }
  }

  private var adminSection: some View {
    Section {
      NavigationLink(destination: RoleManagementView()) {
        Label {
          Text("Gestionar Roles y Permisos")
            .fontWeight(.medium)
        } icon: {
          Image(systemName: "shield.lefthalf.filled")
        }
      }
    } header: {
      Label("Administración Avanzada", systemImage: "shield.checkerboard")
        .sectionHeader(color: tempSettings?.accentColor ?? .accentColor)
    }
  }

  private var saveButton: some View {
    Button(action: {
      let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
      impactFeedback.impactOccurred()

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
      Label {
        Text("Guardar")
          .fontWeight(.semibold)
      } icon: {
        Image(systemName: "checkmark.circle.fill")
      }
      .font(.system(size: 16, weight: .semibold))
      .padding(.vertical, 14)
      .padding(.horizontal, 24)
      .background(
        LinearGradient(
          colors: [
            tempSettings?.accentColor ?? .accentColor,
            (tempSettings?.accentColor ?? .accentColor).opacity(0.8),
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .foregroundColor(.white)
      .cornerRadius(30)
      .shadow(
        color: (tempSettings?.accentColor ?? .accentColor).opacity(0.4), radius: 10, x: 0, y: 5)
    }
    .padding(.trailing, 20)
    .padding(.bottom, 20)
  }

  // MARK: - HELPERS

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

  // MARK: - MODELS

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
}

// MARK: - COMPONENTES UI MODERNOS

struct ModernFormCard<Content: View>: View {
  let content: () -> Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      content()
    }
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 24)
        .fill(Color(.systemBackground))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
  }
}

struct ModernTextField: View {
  let icon: String
  let title: String
  let text: Binding<String>
  var keyboard: UIKeyboardType = .default
  var capitalization: UITextAutocapitalizationType = .none

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(.accentColor)
        .frame(width: 32, height: 32)
        .background(
          Circle()
            .fill(Color.accentColor.opacity(0.1))
        )

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.system(size: 13, weight: .medium))
          .foregroundColor(.secondary)

        TextField(title, text: text)
          .font(.system(size: 16, weight: .medium))
          .keyboardType(keyboard)
          .autocapitalization(capitalization)
          .multilineTextAlignment(.leading)
      }

      Spacer()
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 14)
        .fill(Color(.secondarySystemBackground))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
    )
  }
}

struct ModernToggle: View {
  let icon: String
  let title: String
  let isOn: Binding<Bool>

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(.accentColor)
        .frame(width: 32, height: 32)
        .background(
          Circle()
            .fill(Color.accentColor.opacity(0.1))
        )

      Text(title)
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.primary)

      Spacer()

      Toggle("", isOn: isOn)
        .labelsHidden()
        .tint(.accentColor)
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 14)
        .fill(Color(.secondarySystemBackground))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
    )
  }
}

extension View {
  func sectionHeader(color: Color) -> some View {
    self
      .font(.system(size: 14, weight: .semibold))
      .foregroundColor(color)
      .textCase(.uppercase)
      .padding(.top, 8)
  }
}

// MARK: - PREVIEW

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .environmentObject(SettingsManager.shared)
  }
}
