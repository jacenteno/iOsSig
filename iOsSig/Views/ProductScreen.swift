import SwiftUI
import Combine

struct ProductScreen: View, CameraScannerViewDelegate {
    @StateObject private var viewModel = ProductViewModel()
    @State private var showFilters = false
    @State private var isShowingScanner = false
    @State private var navigateToCambioPrecio = false
    @State private var selectedProductCode: String? = nil
    @EnvironmentObject var settings: SettingsManager
    
    let filterOptions = ["Todos", "Nombre", "Código", "Referencia", "Departamento", "Proveedor", "Bodega"]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Search Bar
                searchHeaderView
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Filter Pills
                if showFilters {
                    filterScrollView
                        .transition(.move(edge: .top).combined(with: .opacity))
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
            .navigationTitle("Productos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarButtons
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                CameraScannerView(delegate: self)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var searchHeaderView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Buscar productos...", text: $viewModel.searchQuery)
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
                
                // Scanner Button
                Button(action: {
                    isShowingScanner = true
                }) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                
                // Filter Toggle
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        showFilters.toggle()
                    }
                }) {
                    Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .font(.title3)
                        .foregroundColor(showFilters ? .white : .accentColor)
                        .frame(width: 44, height: 44)
                        .background(showFilters ? Color.accentColor : Color(.systemGray5))
                        .cornerRadius(12)
                }

                // Clear Button
                Button(action: {
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.bottom, 8)
    }
    
    private var filterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filterOptions, id: \.self) { filter in
                    FilterChipModern(
                        title: filter,
                        isSelected: viewModel.selectedFilterType == filter,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedFilterType = filter
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
    
    private var toolbarButtons: some View {
        HStack(spacing: 16) {
            NavigationLink(destination: CurrentOrderScreen()) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "cart.fill")
                        .font(.title3)
                    
                    if 0 > 0 { // Badge count - replace with actual count
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -4)
                    }
                }
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
            ErrorStateView(message: errorMessage) {
                viewModel.fetchProducts()
            }
        } else if viewModel.products.isEmpty {
            EmptyStateView()
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
                        }
                    )
                    .environmentObject(settings)
                    .environmentObject(viewModel)
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
            NavigationLink(
                destination: selectedProductCode.map { CambioPrecioView(codigo: $0) },
                isActive: $navigateToCambioPrecio
            ) {
                EmptyView()
            }
        )
    }
    
    func didScanBarcode(code: String) {
        viewModel.searchQuery = code
        isShowingScanner = false
    }
}

// MARK: - Modern Filter Chip
struct FilterChipModern: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(.systemGray5))
                )
        }
    }
}

// MARK: - Product Card with Grid Layout (SOLUCIÓN RECOMENDADA)
struct ProductCardView: View {
    let product: Product
    let onNavigateToCambioPrecio: (String) -> Void
    @State private var showDetails = false
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var viewModel: ProductViewModel
    @State private var selectedTab = 0
    @State private var isHacerPedidosActive = false
    @State private var isEtiquetaActive = false
    @State private var showTabContent = true

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
                NavigationLink(destination: HacerPedidosScreen(), isActive: $isHacerPedidosActive) { EmptyView() }
                NavigationLink(destination: EtiquetaScreen(), isActive: $isEtiquetaActive) { EmptyView() }
            }
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .onAppear {
            if viewModel.selectedFilterType == "Código" && viewModel.products.count == 1 {
                withAnimation(.spring()) {
                    showDetails = true
                }
            }
        }
        .onChange(of: isHacerPedidosActive) { newValue in
            if !newValue {
                viewModel.clearSearch()
            }
        }
        .onChange(of: isEtiquetaActive) { newValue in
            if !newValue {
                viewModel.clearSearch()
            }
        }
    }
    
    private var productHeaderView: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                // Product Icon
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "shippingbox.fill")
                        .font(.title)
                        .foregroundColor(.accentColor)
                }
                
                // Product Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.desproducto ?? "Sin nombre")
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let referencia = product.referencia, !referencia.isEmpty {
                        Text(referencia)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.caption)
                        Text(product.codproducto ?? "N/A")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "$%.2f", product.preciodeventa ?? 0.0))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    
                    Text("Precio")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color.accentColor.opacity(0.1))
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
                showDetails.toggle()
                if showDetails {
                    viewModel.fetchProductDetails(for: product)
                }
            }
        }) {
            HStack {
                Text(showDetails ? "Ocultar información" : "Ver información completa")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: showDetails ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
            }
            .foregroundColor(.accentColor)
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        
        if showDetails {
            VStack(spacing: 16) {
                // Grid de acciones 3x2 (NO SCROLL HORIZONTAL)
                actionGridView
                
                if showTabContent {
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
                    isSelected: selectedTab == 0,
                    color: .accentColor
                ) {
                    if selectedTab == 0 {
                        withAnimation { showTabContent.toggle() }
                    } else {
                        withAnimation { 
                            selectedTab = 0
                            showTabContent = true
                        }
                    }
                }
                
                ActionGridButton(
                    icon: "chart.bar.fill",
                    title: "Ventas",
                    isSelected: selectedTab == 1,
                    color: .accentColor
                ) {
                    if selectedTab == 1 {
                        withAnimation { showTabContent.toggle() }
                    } else {
                        withAnimation { 
                            selectedTab = 1
                            showTabContent = true
                        }
                    }
                }
                
                ActionGridButton(
                    icon: "cart.fill",
                    title: "Compras",
                    isSelected: selectedTab == 2,
                    color: .accentColor
                ) {
                    if selectedTab == 2 {
                        withAnimation { showTabContent.toggle() }
                    } else {
                        withAnimation { 
                            selectedTab = 2
                            showTabContent = true
                        }
                    }
                }
            }
            
            // Segunda fila: Acciones
            HStack(spacing: 12) {
                ActionGridButton(
                    icon: "dollarsign.circle.fill",
                    title: "Precio",
                    color: .orange
                ) {
                    onNavigateToCambioPrecio(product.codproducto ?? "")
                }
                
                ActionGridButton(
                    icon: "plus.circle.fill",
                    title: "Pedir",
                    color: .green
                ) {
                    isHacerPedidosActive = true
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
        switch selectedTab {
        case 0:
            ProductDetailsModern(product: product)
                .environmentObject(settings)
        case 1:
            SalesContent2(venta: viewModel.ventas[product.codproducto ?? ""])
        case 2:
            PurchasesContent2(citymallProd: viewModel.citymallProds[product.codproducto ?? ""])
        default:
            EmptyView()
        }
    }
}

// MARK: - Action Grid Button
struct ActionGridButton: View {
    let icon: String
    let title: String
    var isSelected: Bool = false
    var color: Color = .accentColor
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ActionGridButtonLabel(
                icon: icon,
                title: title,
                isSelected: isSelected,
                color: color
            )
        }
    }
}

struct ActionGridButtonLabel: View {
    let icon: String
    let title: String
    var isSelected: Bool = false
    var color: Color = .accentColor
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? color : color.opacity(0.1))
        )
    }
}

// MARK: - Modern Product Details
struct ProductDetailsModern: View {
    let product: Product
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        VStack(spacing: 12) {
            DetailCard(
                icon: "number.circle.fill",
                label: "Código",
                value: product.codproducto ?? "N/A"
            )
            
            DetailCard(
                icon: "building.2.fill",
                label: "Bodega",
                value: product.codbodega ?? "N/A"
            )
            
            DetailCard(
                icon: "square.grid.2x2.fill",
                label: "Departamento",
                value: product.nombre_departamento ?? "N/A"
            )
            
            if settings.userRole.hasPermission("VIEW_INVENTARIO") {
                DetailCard(
                    icon: "cube.box.fill",
                    label: "Existencias",
                    value: "\(product.existencias ?? 0)",
                    highlighted: (product.existencias ?? 0) < 10
                )
            }
            
            if settings.userRole.hasPermission("VIEW_COSTO") {
                DetailCard(
                    icon: "dollarsign.circle.fill",
                    label: "Costo",
                    value: String(format: "$%.2f", product.ultcosto ?? 0.0)
                )
                
                DetailCard(
                    icon: "dollarsign.square.fill",
                    label: "Costo FOB",
                    value: String(format: "$%.2f", product.costofob ?? 0.0)
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

// MARK: - Empty State
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Busca productos")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Ingresa un término de búsqueda o escanea un código de barras para comenzar")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - Error State
struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: retryAction) {
                Text("Reintentar")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct ProductScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProductScreen()
            .environmentObject(SettingsManager.shared)
    }
}
