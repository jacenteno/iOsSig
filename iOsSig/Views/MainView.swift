import SwiftUI

struct MainView: View {
    @EnvironmentObject var settings: SettingsManager
    
    // Estados para controlar la presentación de vistas y alertas
    @State private var showSettings = false
    @State private var showAboutAlert = false
    
    // Estados para la navegación programática desde el menú
    @State private var navigateToCreateProduct = false
    @State private var navigateToSyncProducts = false
    @State private var navigateToOfflineProducts = false
    @State private var navigateToLogs = false
    @State private var navigateToCambioPrecio = false

    @State private var version: String = "1.0" // Placeholder for app version
    @State private var requestCode: String = "ABC-123" // Placeholder for request code

    // Define los items del TabView basados en los roles
    private var tabItems: [TabItem] {
        var items: [TabItem] = []
        let role = settings.userRole

        // La lógica de permisos la puedes ajustar en User.swift
        if role.hasPermission(for: "VIEW_HOME") {
            items.append(TabItem(title: "Inicio", icon: "house.fill", view: AnyView(HomeScreen(version: version, requestCode: requestCode))))
        }
        if role.hasPermission(for: "VIEW_DASHBOARD") { // Add Dashboard with permission check
            items.append(TabItem(title: "Dashboard", icon: "chart.bar.fill", view: AnyView(DashboardScreen())))
        }
        if role.hasPermission(for: "VIEW_PRODUCTS") {
            items.append(TabItem(title: "Productos", icon: "barcode.viewfinder", view: AnyView(ProductScreen())))
        }
        if role.hasPermission(for: "VIEW_PRODUCTS") { // Add Frontera with permission check
            items.append(TabItem(title: "Frontera", icon: "shippingbox.fill", view: AnyView(FronteraScreen())))
        }
        if role.hasPermission(for: "VIEW_CLIENTS") {
            items.append(TabItem(title: "Clientes", icon: "person.2.fill", view: AnyView(Text("Pantalla de Clientes").font(.largeTitle))))
        }
        if settings.useOldApi && role.hasPermission(for: "VIEW_DAVID") {
            items.append(TabItem(title: "David", icon: "person.fill", view: AnyView(Text("Pantalla de David").font(.largeTitle))))
        }
        return items
    }

    var body: some View {
        TabView {
            ForEach(tabItems) {
                item in
                // Cada pestaña tiene su propio NavigationView para mantener su estado de navegación
                // Cada pestaña tiene su propio NavigationView para mantener su estado de navegación
                NavigationView {
                    item.view
                        .navigationTitle(item.title)
                        .toolbar {
                            // Agrupamos los botones de la barra de navegación
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                // Botón de Configuración
                                Button(action: { showSettings = true }) {
                                    Image(systemName: "gearshape.fill")
                                }
                            }
                        }
                }
                .tabItem {
                    VStack {
                        Image(systemName: item.icon)
                        Text(item.title)
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(settings)
        }
        .alert("Acerca de SigApp", isPresented: $showAboutAlert) {
            Button("Cerrar", role: .cancel) {}
        } message: {
            Text("Sistema de Infårmación Gerencial\nVersión: 1.0 (SwiftUI)\n© 2025 JCenteno")
        }
    }
}

struct AppMenuView: View {
    @EnvironmentObject var settings: SettingsManager
    
    // Bindings para controlar alertas y navegación
    @Binding var showAboutAlert: Bool
    @Binding var navigateToCreateProduct: Bool
    @Binding var navigateToSyncProducts: Bool
    @Binding var navigateToOfflineProducts: Bool
    @Binding var navigateToLogs: Bool
    @Binding var navigateToCambioPrecio: Bool // New binding

    var body: some View {
        let role = settings.userRole
        
        Menu {
            // Sección de Gestión
            if role.hasPermission(for: "EDIT_PRICES") || role.hasPermission(for: "CREATE_PRODUCTS") {
                Section(header: Text("Gestión")) {
                    if role.hasPermission(for: "EDIT_PRICES") {
                        Button(action: { navigateToCambioPrecio = true }) { // Updated action
                            Label("Cambio de Precio", systemImage: "pencil")
                        }
                    }
                    if role.hasPermission(for: "CREATE_PRODUCTS") {
                        Button(action: { navigateToCreateProduct = true }) {
                            Label("Crear Productos", systemImage: "plus.square")
                        }
                    }
                }
            }
            
            // Sección de Datos
            if role.hasPermission(for: "VIEW_OFFLINE") {
                Section(header: Text("Datos y Sincronización")) {
                    Button(action: { navigateToSyncProducts = true }) {
                        Label("Traer Productos de PostGreSQL a Local", systemImage: "arrow.triangle.2.circlepath") // Updated label
                    }
                    Button(action: { navigateToOfflineProducts = true }) {
                        Label("Consultar Productos offLine", systemImage: "icloud.slash") // Updated label
                    }
                }
            }
            
            // Sección de Logs
            Section(header: Text("Revisar Logs")) {
                Button(action: { navigateToLogs = true }) {
                    Label("Log", systemImage: "doc.text") // Updated label
                }
            }
            
            // Sección de Información
            Section {
                Button(action: { showAboutAlert = true }) {
                  //  Label("Acerca de", systemName: "info.circle")
                }
            }
            
        } label: {
            // El ícono que se muestra en la barra de navegación
            Image(systemName: "ellipsis.circle")
        }
    }
}


// Estructura para definir un item del TabView
struct TabItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let view: AnyView
}

// --- PANTALLAS ---

// HomeScreen ahora contiene los NavigationLinks para que el menú funcione
struct HomeScreen1: View {
    @Binding var navigateToCreateProduct: Bool
    @Binding var navigateToSyncProducts: Bool
    @Binding var navigateToOfflineProducts: Bool
    @Binding var navigateToLogs: Bool
    @Binding var navigateToCambioPrecio: Bool // New binding

    var body: some View {
        VStack {
            Text("Pantalla de Inicio")
            Image(systemName: "house")
                .font(.largeTitle)
                .padding()
            
            // Links de navegación invisibles, activados por el estado
            NavigationLink(destination: CreaProductoView(), isActive: $navigateToCreateProduct) { EmptyView() }
            NavigationLink(destination: SyncProductsView(), isActive: $navigateToSyncProducts) { EmptyView() }
            NavigationLink(destination: OfflineProductsView(), isActive: $navigateToOfflineProducts) { EmptyView() }
            NavigationLink(destination: ViewLogsScreen(), isActive: $navigateToLogs) { EmptyView() }
            NavigationLink(destination: CambioPrecioView(), isActive: $navigateToCambioPrecio) { EmptyView() } // New NavigationLink
        }
    }
}

struct ProductScreen: View {
    @State private var productCode: String = ""
    @State private var product: Product? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    private let apiService = APIService()

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("Buscar por código", text: $productCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: searchProduct) {
                    Image(systemName: "magnifyingglass")
                }
            }.padding()

            if isLoading {
                ProgressView()
            } else if let product = product {
                productDetailView(product)
            } else if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else {
                Spacer()
                Text("Ingrese un código para buscar un producto.")
                Spacer()
            }
        }
        .onAppear {
            // Esto asegura que la barra de navegación y el título se muestren correctamente
        }
    }
    
    private func searchProduct() {
        isLoading = true
        errorMessage = nil
        product = nil
        
        Task {
            do {
                let foundProduct = try await apiService.getProductByCode(codigo: productCode)
                self.product = foundProduct
            } catch {
                self.errorMessage = "Producto no encontrado o error en la API."
            }
            isLoading = false
        }
    }
    
    @ViewBuilder
    private func productDetailView(_ product: Product) -> some View {
        List {
            Section(header: Text("Información Principal")) {
                Text("Descripción: \(product.desproducto)")
                Text("Referencia: \(product.referencia)")
                Text("Código de Barras: \(product.codigobarra)")
            }
            Section(header: Text("Inventario y Precios")) {
             //   Text("Existencias: \(product.existencias, specifier: \"%.2f\")")
               // Text("Precio de Venta: $\(product.preciodeventa, specifier: \"%.2f\")")
               // Text("Último Costo: $\(product.ultcosto, specifier: \"%.2f\")")
            }
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(SettingsManager.shared)
    }
}
