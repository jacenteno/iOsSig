import SwiftUI
import Combine

struct ProductScreen: View, CameraScannerViewDelegate {
    @StateObject private var viewModel: ProductViewModel
    @State private var showFilters = false
    @State private var isShowingScanner = false
    @State private var navigateToCambioPrecio = false
    @State private var navigateToCreaProducto = false
    @State private var selectedProductCode: String? = nil
    @State private var showOfflineSearch = false // Estado para la búsqueda offline
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var cartManager: CartManager
    @State private var showError: Bool = false // State to control ErrorView presentation

    init() {
        _viewModel = StateObject(wrappedValue: ProductViewModel(settings: .shared))
    }
    
    let filterOptions = ["Nombre", "Código", "Referencia"]

    var body: some View {
        VStack(spacing: 0) {
            // Enhanced Search Bar
            searchHeaderView
                .padding(.horizontal)
                .padding(.top, 8)
            
            // Filter Pills
            if showFilters {
                filterScrollView
            }
            
            // Content Area
            contentView
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarButtons
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            CameraScannerView(delegate: self)
        }
        .sheet(isPresented: $showError) {
            ErrorView(errorMessage: viewModel.errorMessage ?? "Error desconocido", retryAction: { viewModel.fetchProducts() }, isShowingError: $showError)
        }
        .alert("Producto no encontrado", isPresented: $viewModel.showCreateProductAlert) {
            Button("Sí") {
                print("ProductScreen: 'Sí' button tapped at \(Date())")
                navigateToCreaProducto = true
            }
            Button("No", role: .cancel) { }
        } message: {
            Text("El producto con el código \(viewModel.productNotFoundCode ?? "") no existe. ¿Desea crearlo?")
        }
        .sheet(isPresented: $navigateToCreaProducto) {
            CreaProductoView(codigoDeReferencia: viewModel.productNotFoundCode)
        }
        .sheet(isPresented: $showOfflineSearch) {
            NavigationView {
                OfflineProductsView(isPresented: $showOfflineSearch)
            }
        }
        .onAppear {
            if let productCode = settings.selectedProductCodeForSearch {
                viewModel.selectedFilterType = "Código"
                viewModel.searchQuery = productCode
                viewModel.searchProductByCode()
                settings.selectedProductCodeForSearch = nil
            }
        }
        .onChange(of: settings.selectedProductCodeForSearch) { newValue in
            print("DEBUG: ProductScreen.onChange(selectedProductCodeForSearch) triggered with: \(newValue ?? "nil")")
            if let productCode = newValue {
                viewModel.selectedFilterType = "Código"
                viewModel.searchQuery = productCode
                viewModel.searchProductByCode()
                settings.selectedProductCodeForSearch = nil
            }
        }
    }
    
    // MARK: - Subviews
    
    private var searchHeaderView: some View {
        HStack(spacing: 12) {
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar productos...", text: $viewModel.searchQuery, onCommit: {
                    viewModel.searchProductByCode()
                })
                .textFieldStyle(.plain)
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        withAnimation {
                            viewModel.searchQuery = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray5))
            .cornerRadius(12)

            // Action Buttons
            HStack(spacing: 0) {
                Button(action: {
                    viewModel.searchProductByCode()
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }
                .disabled(viewModel.searchQuery.isEmpty)
                .padding(10)

                Divider().frame(height: 20)

                Button(action: {
                    isShowingScanner = true
                }) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title3)
                }
                .padding(10)

                Divider().frame(height: 20)

                Button(action: {
                    showOfflineSearch = true
                }) {
                    Image(systemName: "archivebox.fill")
                        .font(.title3)
                }
                .padding(10)

                Divider().frame(height: 20)

                Button(action: {
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "trash")
                        .font(.title3)
                }
                .padding(10)
            }
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.bottom, 8)
    }
    
    private var filterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filterOptions, id: \.self) { filter in
                    Button(filter) {
                        viewModel.selectedFilterType = filter
                        if !viewModel.searchQuery.isEmpty {
                            viewModel.fetchProducts()
                        }
                    }
                    .buttonStyle(FilterChipButtonStyle(isSelected: viewModel.selectedFilterType == filter))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .onAppear { print("filterScrollView appeared") }
        .onDisappear { print("filterScrollView disappeared") }
    }
    
    private var toolbarButtons: some View {
        HStack(spacing: 16) {
            NavigationLink(destination: HacerPedidosScreen()) {
                CartBadgeView()
            }
            
            NavigationLink(destination: OrdersListScreen()) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title3)
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            VStack {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Text("Cargando productos...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
                Spacer()
            }
        } else if let errorMessage = viewModel.errorMessage {
            Color.clear.onAppear {
                showError = true
            }
        } else if viewModel.products.isEmpty {
            EmptyStateView(systemImage: "magnifyingglass", message: "Busca productos por nombre, código o referencia.")
        } else {
            productsListView
        }
    }
            
            private var productsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.products) { product in
                    ProductCardView(
                        product: product,
                        onNavigateToCambioPrecio: { productCode in
                            selectedProductCode = productCode
                            navigateToCambioPrecio = true
                        },
                        productSource: viewModel.productSource // Pass the source here
                    )
                    .environmentObject(settings)
                    .environmentObject(viewModel)
                    .environmentObject(cartManager)
                    .onAppear {
                        if product.id == viewModel.products.last?.id && viewModel.canLoadMorePages {
                            viewModel.loadMoreProducts()
                        }
                    }
                }
            }
            .padding()
        }
        .background(
            Group {
                if let productCode = selectedProductCode {
                    NavigationLink(
                        destination: CambioPrecioView(codigo: productCode).environmentObject(viewModel),
                        isActive: $navigateToCambioPrecio
                    ) {
                        EmptyView()
                    }
                }
            }
        )
    }
    
    func didScanBarcode(code: String) {
        viewModel.searchQuery = code
        isShowingScanner = false
    }
}

// MARK: - Product Card with Grid Layout (SOLUCIÓN RECOMENDADA)
struct ProductCardView: View {
    let product: Product
    let onNavigateToCambioPrecio: (String) -> Void
    var productSource: DataSource? = nil // Add this line
    @StateObject private var cardViewModel = ProductCardViewModel()
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var viewModel: ProductViewModel
    @EnvironmentObject var cartManager: CartManager
    @State private var isHacerPedidosActive = false
    @State private var isEtiquetaActive = false
    @State private var isShowingAddProductSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Main Product Info
            productHeaderView
                .padding()
            
            // Expandable Details
            detailsSection
        }
        .background(
            VStack {
                NavigationLink(destination: HacerPedidosScreen().environmentObject(cartManager), isActive: $isHacerPedidosActive) { EmptyView() }
                NavigationLink(destination: EtiquetaScreen(product: product), isActive: $isEtiquetaActive) { EmptyView() }
            }
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .onAppear {
            cardViewModel.loadProductDetails(for: product) // New: Call to load details
            if viewModel.selectedFilterType == "Código" && viewModel.products.count == 1 {
                withAnimation(.spring()) {
                    cardViewModel.showDetails = true
                }
            }
        }

        .sheet(isPresented: $isShowingAddProductSheet) {
            AddProductToOrderView(product: product)
                .environmentObject(cartManager)
        }
    }
    
    private var productHeaderView: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                // Product Icon
               //ZStack {
                 //   Circle()
                ///        .fill(Color.accentColor.opacity(0.1))
                 //       .frame(width: 60, height: 60)
                  //
                  //  Image(systemName: "ticket.fill")
                  //      .font(.title)
                  //      .foregroundColor(.accentColor)
                //}
                
                // Product Details
                VStack(alignment: .leading, spacing: 4) { // Increased spacing a bit
                    HStack {
                        Text(product.desproducto ?? "Sin nombre")
                            .font(.headline)
                            .lineLimit(4)
                        
                        // SIMULATED ALERT ICON
                        if (product.existencias ?? 0) < 25 {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                    
                    if let referencia = product.referencia, !referencia.isEmpty {
                        Text(referencia)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text(product.codproducto ?? "N/A")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.secondary)
                    
                    // Product Source Indicator (MOVED HERE)
                    if let source = productSource {
                        HStack(spacing: 4) {
                            Image(systemName: source == .api ? "wifi" : "archivebox.fill")
                                .font(.caption2) // Smaller icon
                                .foregroundColor(source == .api ? .green : .gray)
                            Text(source == .api ? "Online" : "Local") // Changed text
                                .font(.caption2) // Smaller text
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "$%.2f", product.preciodeventa ?? 0.0))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .minimumScaleFactor(0.5)
                    
                    Text("Precio Regular")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red)
                        .cornerRadius(4)
                }
                .padding(8)
               // .background(Color.customPinkRed.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .onTapGesture(count: 2) {
            if viewModel.selectedFilterType != "Código" {
                viewModel.showProductAsSingleResult(product)
            }
        }
    }
    
            @ViewBuilder
    
            private var detailsSection: some View {
    
                Divider()
    
                    .padding(.horizontal)
    
                
    
                Button(action: {
    
                    withAnimation(.spring(response: 0.3)) {
    
                        cardViewModel.showDetails.toggle()
    
                        if cardViewModel.showDetails {
                            cardViewModel.fetchVentas(for: product) { _ in }
                        }
    
                    }
    
                }) {
    
                    HStack {
    
                        Text(cardViewModel.showDetails ? "Ocultar información" : "Ver información completa")
    
                            .font(.subheadline)
    
                            .fontWeight(.medium)
    
                        Spacer()
    
                        Image(systemName: cardViewModel.showDetails ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
    
                    }
    
                    .foregroundColor(.accentColor)
    
                    .padding(.horizontal)
    
                    .padding(.vertical, 12)
    
                }
    
                
    
                if cardViewModel.showDetails {
    
                    VStack(spacing: 16) {
    
                        // Grid de acciones 3x2 (NO SCROLL HORIZONTAL)
    
                        actionGridView
    
                        
    
                        if cardViewModel.showTabContent {
    
                            Divider()
    
                                .padding(.horizontal)
    
                            
    
                            // Content based on selection
    
                            tabContentView
    
                                .transition(.opacity)
    
                        }
    
                    }
    
                    .padding(.horizontal)
    
                    .padding(.bottom)
    
                }
    
            }
    
            
    
            private var actionGridView: some View {
    
                VStack(spacing: 12) {
    
                    // Primera fila: Tabs de visualización
    
                    HStack(spacing: 12) {
    
                        ActionGridButton(
    
                            icon: "info.circle.fill",
    
                            title: "Detalles",
    
                            isSelected: cardViewModel.selectedTab == 0,
    
                            color: .accentColor
    
                        ) {
    
                            if cardViewModel.selectedTab == 0 {
    
                                withAnimation { cardViewModel.showTabContent.toggle() }
    
                            } else {
    
                                withAnimation { 
    
                                    cardViewModel.selectedTab = 0
    
                                    cardViewModel.showTabContent = true
    
                                }
    
                            }
    
                        }
    
                        
    
                        ActionGridButton(
    
                            icon: "chart.bar.fill",
    
                            title: "Ventas",
    
                            isSelected: cardViewModel.selectedTab == 1,
    
                            color: .accentColor
    
                        ) {
                            if settings.desplegarVentasApiOld {
                                cardViewModel.fetchCompras(for: product) { success in
                                    if success {
                                        if cardViewModel.selectedTab == 1 {
                                            withAnimation { cardViewModel.showTabContent.toggle() }
                                        } else {
                                            withAnimation { 
                                                cardViewModel.selectedTab = 1
                                                cardViewModel.showTabContent = true
                                            }
                                        }
                                    }
                                }
                            } else {
                                cardViewModel.fetchVentas(for: product) { success in
                                    if success {
                                        if cardViewModel.selectedTab == 1 {
                                            withAnimation { cardViewModel.showTabContent.toggle() }
                                        } else {
                                            withAnimation { 
                                                cardViewModel.selectedTab = 1
                                                cardViewModel.showTabContent = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
    
                        
                        if settings.desplegarComprasApiOld {
                            ActionGridButton(
        
                                icon: "cart.fill",
        
                                title: "Compras",
        
                                isSelected: cardViewModel.selectedTab == 2,
        
                                color: .accentColor
        
                            ) {
        
                                cardViewModel.fetchCompras(for: product) { success in
                                    if success {
                                        if cardViewModel.selectedTab == 2 {
                                            withAnimation { cardViewModel.showTabContent.toggle() }
                                        } else {
                                            withAnimation { 
                                                cardViewModel.selectedTab = 2
                                                cardViewModel.showTabContent = true
                                            }
                                        }
                                    }
                                }
        
                            }
                        }
    
                    }
    
                    
    
                    // Segunda fila: Acciones
    
                    HStack(spacing: 12) {
    
                        ActionGridButton(
    
                            icon: "dollarsign.circle.fill",
    
                            title: "Cambios P.",
    
                            color: .orange
    
                        ) {
    
                            onNavigateToCambioPrecio(product.codproducto ?? "")
    
                        }
    
                        
    
                        ActionGridButton(
    
                            icon: "plus.circle.fill",
    
                            title: "Pedir",
    
                            color: .green
    
                        ) {
    
                            isShowingAddProductSheet = true
    
                        }
    
                        
    
                        ActionGridButton(
    
                            icon: "printer.fill",
    
                            title: "Etiqueta",
    
                            color: .purple
    
                        ) {
    
                            isEtiquetaActive = true
    
                        }
    
                    }
    
                }
    
            }
    
            
    
            @ViewBuilder
    
            private var tabContentView: some View {
    
                switch cardViewModel.selectedTab {
    
                                case 0:
                
                                    ProductDetailsModern(product: product, cmdProductDetails: cardViewModel.cmdProductDetails)
                
                                        .environmentObject(settings)    
                                case 1:
                    if settings.desplegarVentasApiOld {
                        if let citymallProd = cardViewModel.citymallProd {
                            NewSalesDetailView(sales: citymallProd.ventas)
                        } else {
                            ProgressView()
                        }
                    } else {
                        if let venta = cardViewModel.venta {
                            SalesDetailView(venta: venta)
                                .id(venta.id)
                        } else {
                            ProgressView()
                        }
                    }
    
                case 2:
    
                    if let citymallProd = cardViewModel.citymallProd {
    
                        PurchasesDetailView(citymallProd: citymallProd)
    
                    }
    
                    else {
    
                        ProgressView()
    
                    }
    
                default:
    
                    EmptyView()
    
                }
    
            }
    

}


// MARK: - Modern Product Details
struct ProductDetailsModern: View {
    let product: Product
    var cmdProductDetails: ProductDetails? // New property
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        VStack(spacing: 12) {
            DetailCard(
                    icon: "paperclip.circle.fill",
                    label: "Cod.Producto",
                    value: product.codproducto?.replacingOccurrences(of: " ", with: "") ?? "N/A"
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
            DetailCard(
                    icon: "number.circle.fill",
                    label: "Ref.",
                    value: product.codigobarra?.replacingOccurrences(of: " ", with: "") ?? "N/A"
                )                .frame(maxWidth: .infinity, alignment: .trailing)

            DetailCard(
                icon: "building.2.fill",
                label: "Bodega",
                value: product.codbodega ?? "N/A"
            )

            DetailCard(
                icon: "square.grid.2x2.fill",
                label: "Departamento",
                value: product.nombre_departamento?.replacingOccurrences(of: " ", with: "") ?? "N/A"
            )                .frame(maxWidth: .infinity, alignment: .trailing)


            if settings.userRole.hasPermission("VIEW_INVENTARIO") {
                let stockValue = cmdProductDetails?.existencia ?? (product.existencias != nil ? Int(product.existencias!) : 0)
                HStack(spacing: 12) {
                    Image(systemName: "cube.box.fill")
                        .font(.body)
                        .foregroundColor(.accentColor)
                        .frame(width: 24)
                    
                    Text("Existencias")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(stockValue)")
                        .font(.title) // Larger font
                        .fontWeight(.bold)
                        .foregroundColor(stockValue > 0 ? .green : .red) // Conditional color
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }

            if settings.userRole.hasPermission("VIEW_COSTO") {
                DetailCard(
                    icon: "dollarsign.circle.fill",
                    label: "Costo",
                    value: String(format: "$%.6f", cmdProductDetails?.costo ?? product.ultcosto ?? 0.0) // Prioritize cmdProductDetails
                )

                DetailCard(
                    icon: "dollarsign.square.fill",
                    label: "Costo FOB",
                    value: String(format: "$%.6f", cmdProductDetails?.costoFob ?? product.costofob ?? 0.0) // Prioritize cmdProductDetails
                )
            }

            DetailCard(
                icon: "calendar.badge.clock",
                label: "F. Vencimiento",
                value: convertClarionDateToString(clarionDate: product.fvencimiento)
            )

            DetailCard(
                icon: (product.bloqueofacturacion ?? 0) == 1 ? "lock.fill" : "lock.open.fill",
                label: "Facturación",
                value: (product.bloqueofacturacion ?? 0) == 1 ? "Bloqueado" : "Activo",
                highlighted: (product.bloqueofacturacion ?? 0) == 1
            )

            DetailCard(
                icon: "percent",
                label: "Gravado/Exento",
                value: product.gravadoexecto ?? "N/A"
            )
        }
    }
}

struct DetailCard: View {
    let icon: String
    let label: String
    let value: String
    var highlighted: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(highlighted ? .orange : .accentColor)
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(highlighted ? .orange : .primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}




// MARK: - Preview
struct ProductScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProductScreen()
            .environmentObject(SettingsManager.shared)
            .environmentObject(CartManager())
    }
}
