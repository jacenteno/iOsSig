import SwiftUI
import Charts // Requires iOS 16+

struct DashboardScreen: View {
    @EnvironmentObject var settings: SettingsManager
    @StateObject var viewModel: HomeViewModel

    @State private var refreshCountdown: Int = 45
    private let refreshInterval: Int = 45
    @State private var showError: Bool = false
    
    // State for Share functionality
    @State private var capturedImage: UIImage?
    @State private var isShowingShareSheet = false
    @State private var contentHeight: CGFloat = .zero
    
    // Animation states
    @State private var cardsAppeared = false
    @Namespace private var animation

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }

    var body: some View {
        ZStack {
                // Modern gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color.customPrimary.opacity(0.03),
                        Color.customTeal.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if viewModel.isLoading && viewModel.ventaPorGrupoCaja.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Cargando datos...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if let error = viewModel.error {
                    if !viewModel.products.isEmpty {
                        List(viewModel.products) { product in
                            VStack(alignment: .leading) {
                                Text(product.desproducto ?? "Nombre no disponible")
                                    .font(.headline)
                                Text("Código: \(product.codproducto ?? "N/A")")
                                    .font(.subheadline)
                            }
                        }
                    } else {
                        Color.clear.onAppear {
                            showError = true
                        }
                    }
                } else {
                    ScrollView {
                        dashboardContent
                            .padding(.top, 8)
                    }
                    .refreshable {
                        viewModel.fetchSalesData()
                        self.refreshCountdown = self.refreshInterval
                    }
                }
            }
            .sheet(isPresented: $showError) {
                ErrorView(errorMessage: viewModel.error ?? "Error desconocido", retryAction: { viewModel.fetchSalesData() }, isShowingError: $showError)
            }
            .sheet(isPresented: $isShowingShareSheet) {
                if let image = capturedImage {
                    ShareSheet(activityItems: [image, "Informe de Dashboard - \(Date().formatted())"])
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        self.capturedImage = dashboardContent.asImage(size: CGSize(width: UIScreen.main.bounds.width, height: contentHeight))
                        self.isShowingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                            )
                    }
                    
                    NavigationLink(destination: ProactiveAssistantView()) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.1))
                                .frame(width: 36, height: 36)
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                        }
                    }
                }
            }

        .onAppear {
            viewModel.fetchSalesData()
            setupRefreshTimer()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                cardsAppeared = true
            }
        }
    }
    
    private var dashboardContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Hero Section - Venta Final
            heroSection
                .opacity(cardsAppeared ? 1 : 0)
                .offset(y: cardsAppeared ? 0 : -20)
            
            // Stats Grid
            statsGrid
                .opacity(cardsAppeared ? 1 : 0)
                .offset(y: cardsAppeared ? 0 : 20)
            
            // Charts Section
            chartsSection
                .opacity(cardsAppeared ? 1 : 0)
            
            // Details Section
            detailsSection
                .opacity(cardsAppeared ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .background(
            GeometryReader { proxy in
                Color.clear.onAppear { self.contentHeight = proxy.size.height }
            }
        )
    }
    
    private var heroSection: some View {
        VStack(spacing: 0) {
            // Glassmorphism card effect
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.customPinkRed.opacity(0.8),
                                Color.customPrimary.opacity(0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.customPinkRed.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Text("Venta Final Neta")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(String(format: "$%.2f", viewModel.totalMontoFinal))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right.circle.fill")
                                .font(.caption)
                            Text("\(viewModel.totalTransacciones) transacciones")
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text.fill")
                                .font(.caption)
                            Text("\(viewModel.totalTickets) tickets")
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(24)
            }
            .frame(height: 180)
        }
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ModernStatCard(
                title: "Tickets",
                value: viewModel.totalTickets == 0 ? "No Ticket Realizado" : "\(viewModel.totalTickets)",
                icon: "doc.text.fill",
                iconColor: .customPinkRed,
                gradientColors: [Color.customPinkRed.opacity(0.1), Color.customPinkRed.opacity(0.05)]
            )
            .transition(.scale.combined(with: .opacity))
            
            ModernStatCard(
                title: "Clientes",
                value: "\(viewModel.totalClientes)",
                icon: "person.2.fill",
                iconColor: .customOrange,
                gradientColors: [Color.customOrange.opacity(0.1), Color.customOrange.opacity(0.05)]
            )
            .transition(.scale.combined(with: .opacity))

            ModernStatCard(
                title: "Ingresos",
                value: String(format: "$%.2f", viewModel.totalMontoIngreso),
                icon: "arrow.up.right",
                iconColor: .customGreen,
                gradientColors: [Color.customGreen.opacity(0.1), Color.customGreen.opacity(0.05)]
            )
            .transition(.scale.combined(with: .opacity))
            
            ModernStatCard(
                title: "Egresos",
                value: String(format: "$%.2f", viewModel.totalMontoEgreso),
                icon: "arrow.down.left",
                iconColor: .customError,
                gradientColors: [Color.customError.opacity(0.1), Color.customError.opacity(0.05)]
            )
            .transition(.scale.combined(with: .opacity))
            
            ModernStatCard(
                title: "Descuentos",
                value: String(format: "$%.2f", viewModel.finalDescuento),
                icon: "tag.fill",
                iconColor: .customDeepPurple,
                gradientColors: [Color.customDeepPurple.opacity(0.1), Color.customDeepPurple.opacity(0.05)]
            )
            .transition(.scale.combined(with: .opacity))
            
            ModernStatCard(
                title: "N. Crédito",
                value: String(format: "$%.2f", viewModel.totalMontoNotaCredito),
                icon: "creditcard.fill",
                iconColor: .customTeal,
                gradientColors: [Color.customTeal.opacity(0.1), Color.customTeal.opacity(0.05)]
            )
            .transition(.scale.combined(with: .opacity))
            
            ModernStatCard(
                title: "Total Factura Mes",
                value: String(format: "$%.2f", viewModel.totalFacturaDelMes),
                icon: "calendar",
                iconColor: .blue,
                gradientColors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)]
            )
            .transition(.scale.combined(with: .opacity))
            
            ModernStatCard(
                title: "Trans. Caja Grupo",
                value: "\(viewModel.totalTransaccionCajaGrupo)",
                icon: "person.3.fill",
                iconColor: .purple,
                gradientColors: [Color.purple.opacity(0.1), Color.purple.opacity(0.05)]
            )
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    private var chartsSection: some View {
        VStack(spacing: 16) {
            // Ventas por Área
            ModernChartCard(title: "Ventas por Área", icon: "chart.bar.fill", iconColor: .customPrimary) {
                Chart(viewModel.salesByAreaForChart) { item in
                    BarMark(
                        x: .value("Ventas", item.monto),
                        y: .value("Área", item.nombre.trimmingCharacters(in: .whitespaces))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.customPrimary, Color.customPrimary.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(6)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .chartLegend(.hidden)
                .frame(height: 220)
            }
            
            // Ventas por Hora
            ModernChartCard(title: "Ventas por Hora", icon: "clock.fill", iconColor: .customOrange) {
                Chart(viewModel.salesByHourForChart) { item in
                    BarMark(
                        x: .value("Hora", item.hour),
                        y: .value("Ventas", item.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.customOrange, Color.customOrange.opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(6)
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .frame(height: 220)
            }
            
            // Ventas por Caja
            ModernChartCard(title: "Ventas por Caja", icon: "square.grid.2x2.fill", iconColor: .customTeal) {
                Chart(viewModel.allCashRegistersForChart.sorted(by: { $0.monto > $1.monto })) { register in
                    BarMark(
                        x: .value("Monto", register.monto),
                        y: .value("Caja", register.nombre)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.customTeal, Color.customTeal.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(6)
                    .annotation(position: .trailing, alignment: .leading) {
                        HStack(spacing: 4) {
                            Text(String(format: "$%.2f", register.monto))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("(\(register.transacciones))")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .chartLegend(.hidden)
                .frame(height: 280)
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.rectangle.fill")
                    .font(.title3)
                    .foregroundColor(.customPrimary)
                Text("Detalle por Área y Caja")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            if viewModel.ventaPorGrupoCajaDetalle.isEmpty {
                DashboardEmptyStateView()
            } else {
                ForEach(viewModel.ventaPorGrupoCajaDetalle.values.sorted(by: { $0.nombre < $1.nombre })) { areaData in
                    ModernSalesAreaDetailCard(areaData: areaData)
                }
            }
        }
    }

    private func setupRefreshTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.refreshCountdown > 0 {
                self.refreshCountdown -= 1
            } else {
                self.refreshCountdown = self.refreshInterval
            }
        }
    }
}

// --- Modern Helper Views ---

struct ModernStatCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    let gradientColors: [Color]
    
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.15))
                    )
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(iconColor.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

struct ModernChartCard<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: () -> Content

    init(title: String, icon: String, iconColor: Color, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.15))
                    )
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct ModernSalesAreaDetailCard: View {
    let areaData: AreaDetail
    @State private var expanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    expanded.toggle()
                }
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.customPrimary.opacity(0.2), Color.customPrimary.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "desktopcomputer")
                            .font(.system(size: 20))
                            .foregroundColor(.customPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(areaData.nombre.trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.customGreen)
                                Text("$\(areaData.totalMonto, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.customGreen)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.left.arrow.right.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(areaData.totalTransacciones)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: expanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.title3)
                        .foregroundColor(expanded ? .customPrimary : .secondary)
                        .rotationEffect(.degrees(expanded ? 0 : 0))
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())

            if expanded {
                Divider()
                    .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    if areaData.cajas.isEmpty {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                            Text("No hay cajas registradas")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    } else {
                        ForEach(areaData.cajas.values.sorted(by: { $0.monto > $1.monto })) { registerDetail in
                            ModernCashRegisterRow(registerDetail: registerDetail)
                        }
                    }
                }
                .padding(.vertical, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(expanded ? Color.customPrimary.opacity(0.2) : Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(expanded ? 0.08 : 0.04), radius: expanded ? 12 : 6, x: 0, y: expanded ? 6 : 3)
    }
}

struct ModernCashRegisterRow: View {
    let registerDetail: CashRegisterDetail

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "point.3.connected.trianglepath.fill")
                .font(.system(size: 14))
                .foregroundColor(.customTeal)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Color.customTeal.opacity(0.1))
                )
            
            Text(registerDetail.nombre.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("\(registerDetail.transacciones)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.secondary.opacity(0.7))
                    )
                
                Text(String(format: "$%.2f", registerDetail.monto))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.customGreen)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.customTeal.opacity(0.03))
        )
        .padding(.horizontal, 16)
    }
}

struct DashboardEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No hay datos disponibles")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Los detalles aparecerán aquí cuando haya información")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

extension Color {
    static let customPrimary = Color.red
    static let customError = Color.red
    static let customOrange = Color(red: 0xFF / 255.0, green: 0xA0 / 255.0, blue: 0x00 / 255.0)
    static let customGreen = Color(red: 0x38 / 255.0, green: 0x8E / 255.0, blue: 0x3C / 255.0)
    static let customDeepPurple = Color(red: 0x5E / 255.0, green: 0x35 / 255.0, blue: 0xB1 / 255.0)
    static let customTeal = Color(red: 0x00 / 255.0, green: 0x89 / 255.0, blue: 0x7B / 255.0)
    static let customPinkRed = Color(red: 0xD8 / 255.0, green: 0x1B / 255.0, blue: 0x60 / 255.0)
}

struct DashboardScreen_Previews: PreviewProvider {
    static var previews: some View {
        DashboardScreen()
            .environmentObject(SettingsManager.shared)
    }
}
