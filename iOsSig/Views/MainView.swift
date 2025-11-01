import SwiftUI

struct MainView: View {
    @EnvironmentObject var settings: SettingsManager
    
    // Estados para controlar la presentación de vistas y alertas
    @State private var showSettings = false
    @State private var showAboutAlert = false
    @State private var showSyncView = false // Estado para la navegación de Sync
    @State private var refreshID = UUID() // New state variable for refreshing UI

    // Estados para la navegación programática desde el menú

    @State private var version: String = "1.0.231025-jcenteno" // Placeholder for app version
    @State private var requestCode: String = "iOS CM" // Placeholder for request code

    // Define los items del TabView basados en los roles
    private var tabItems: [TabItem] {
        var items: [TabItem] = []
        let role = settings.userRole

        // La lógica de permisos la puedes ajustar en UserRole.swift
        if role.hasPermission("VIEW_HOME") {
            items.append(TabItem(title: "Inicio", icon: "house.fill", view: AnyView(HomeScreen(version: version, requestCode: requestCode, showSettings: $showSettings))))
        }
        if role.hasPermission("VIEW_DASHBOARD") { // Add Dashboard with permission check
            items.append(TabItem(title: "Panel Vtas", icon: "chart.bar.fill", view: AnyView(DashboardScreen())))
        }
        if role.hasPermission("VIEW_PRODUCTS") {
            items.append(TabItem(title: "Productos", icon: "barcode.viewfinder", view: AnyView(ProductScreen())))
        }
        if role.hasPermission("VIEW_FRONTERA") { // Add Frontera with permission check
            items.append(TabItem(title: "Frontera", icon: "shippingbox.fill", view: AnyView(FronteraScreen())))
        }
        if role.hasPermission("VIEW_ORDERS_LIST") {
            items.append(TabItem(title: "Pedidos", icon: "list.bullet.rectangle.fill", view: AnyView(OrdersListScreen())))
        }
        if role.hasPermission("VIEW_CLIENTS") {
            items.append(TabItem(title: "CityPuntos", icon: "person.2.fill", view: AnyView(ClienteScreen())))
        }
        if role.hasPermission("VIEW_PRODUCTS") { // Assuming VIEW_PRODUCTS is sufficient for offline consultation
            items.append(TabItem(title: "Consulta Offline", icon: "magnifyingglass", view: AnyView(OfflineProductsView())))
        }
        if settings.useOldApi && role.hasPermission("VIEW_DAVID") {
          //  items.append(TabItem(title: "David", icon: "person.fill", view: AnyView(Text("Muy Pronto").font(.largeTitle))))
        }
        return items
    }

    var body: some View {
        TabView {
            ForEach(tabItems) {
                item in
                NavigationView {
                    item.view
                        .navigationTitle(item.title)
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                AppMenuView(showAboutAlert: $showAboutAlert, showSyncView: $showSyncView)
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
        .id(refreshID) // Apply refreshID to force re-render of TabView
        .sheet(isPresented: $showSettings, onDismiss: { // Add onDismiss action
            refreshID = UUID() // Change refreshID to force MainView to re-evaluate its body
        }) {
            SettingsView().environmentObject(settings)
        }
        .sheet(isPresented: $showSyncView) { // Present SyncProductsView as a sheet
            NavigationView { SyncProductsView() }
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
    @StateObject private var syncViewModel = SyncProductsViewModel.shared
    
    // Bindings para controlar alertas y navegación
    @Binding var showAboutAlert: Bool
    @Binding var showSyncView: Bool

    var body: some View {
        Menu {
            // Sección de Herramientas
            Section(header: Text("Herramientas")) {
                Button(action: { showSyncView = true }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sincronizar Productos")
                    }
                }
            }

            // Sección de Información
            Section(header: Text("Información")) {
                Button(action: { showAboutAlert = true }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Acerca de")
                    }
                }
            }
        } label: {
            HStack {
                if syncViewModel.isSyncing {
                    ProgressView()
                        .padding(.trailing, 4)
                }
                Image(systemName: "ellipsis.circle")
            }
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(SettingsManager.shared)
    }
}
