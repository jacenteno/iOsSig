import SwiftUI
import Charts

struct DashboardScreen: View {
    @EnvironmentObject var settings: SettingsManager
    @StateObject var viewModel: HomeViewModel

    @State private var refreshCountdown: Int = 45
    private let refreshInterval: Int = 45
    @State private var showError: Bool = false

    @State private var capturedImage: UIImage?
    @State private var isShowingShareSheet = false
    @State private var contentHeight: CGFloat = .zero

    @State private var cardsAppeared = false
    @Namespace private var animation

    // State for password protection
    @State private var isUnlocked = false
    @State private var showLockScreen = false

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }

    var body: some View {
        ZStack {
            // FONDO GRADIENTE ULTRA MODERNO
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    Color.blue.opacity(0.04),
                    Color.green.opacity(0.02)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if isUnlocked {
                if viewModel.isLoading && viewModel.ventaPorGrupoCaja.isEmpty {
                    loadingView
                } else if let error = viewModel.error {
                    if !viewModel.products.isEmpty {
                        productListView
                    } else {
                        Color.clear.onAppear { showError = true }
                    }
                } else {
                    ScrollView {
                        dashboardContent
                            .padding(.top, 8)
                    }
                    .refreshable {
                        viewModel.fetchSalesData()
                        refreshCountdown = refreshInterval
                    }
                }
            } else {
                if !showLockScreen {
                    VStack {
                        Image(systemName: "hand.raised.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No autorizado para esta area")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                } else {
                    // Placeholder while locked and lock screen is appearing
                    EmptyView()
                }
            }
        }
        .fullScreenCover(isPresented: $showLockScreen) {
            AccesoScreen(isUnlocked: $isUnlocked, showLockScreen: $showLockScreen)
        }
        .sheet(isPresented: $showError) {
            ErrorView(
                errorMessage: viewModel.error ?? "Error desconocido",
                retryAction: { viewModel.fetchSalesData() },
                isShowingError: $showError
            )
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
                shareButton
                proactiveAssistantButton
            }
        }
        .onAppear {
            if settings.hasPermission("PEDIR_CLAVE_DASHBOARD") {
                isUnlocked = false
                showLockScreen = true
            } else {
                isUnlocked = true
            }
        }
        .onChange(of: isUnlocked) { unlocked in
            if unlocked {
                viewModel.fetchSalesData()
                setupRefreshTimer()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    cardsAppeared = true
                }
            }
        }
    }

    // MARK: - VIEWS

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.accentColor)
            Text("Cargando datos...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var productListView: some View {
        List(viewModel.products) { product in
            VStack(alignment: .leading, spacing: 4) {
                Text(product.desproducto ?? "Nombre no disponible")
                    .font(.system(size: 16, weight: .semibold))
                Text("Código: \(product.codproducto ?? "N/A")")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }

    private var dashboardContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            heroSection
                .opacity(cardsAppeared ? 1 : 0)
                .offset(y: cardsAppeared ? 0 : -30)

            statsGrid
                .opacity(cardsAppeared ? 1 : 0)
                .offset(y: cardsAppeared ? 0 : 30)

            chartsSection
                .opacity(cardsAppeared ? 1 : 0)
                .offset(y: cardsAppeared ? 0 : 30)

            detailsSection
                .opacity(cardsAppeared ? 1 : 0)
                .offset(y: cardsAppeared ? 0 : 30)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .background(
            GeometryReader { proxy in
                Color.clear.onAppear { contentHeight = proxy.size.height }
            }
        )
    }

    // MARK: - HERO SECTION

    private var heroSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .pink.opacity(0.4), radius: 20, x: 0, y: 10)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.6))
                }

                Text("Venta Final Neta")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))

                Text(String(format: "$%.2f", viewModel.totalMontoFinal))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right.circle.fill")
                            .font(.system(size: 14))
                        Text("\(viewModel.totalTransacciones) transacciones")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white.opacity(0.9))

                    HStack(spacing: 6) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 14))
                        Text("\(viewModel.totalTickets) tickets")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(24)
        }
        .frame(height: 200)
    }

    // MARK: - STATS GRID

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ModernStatCard(
                title: "Tickets",
                value: viewModel.totalTickets == 0 ? "No Ticket" : "\(viewModel.totalTickets)",
                icon: "doc.text.fill",
                iconColor: .pink,
                gradientColors: [Color.pink.opacity(0.15), Color.pink.opacity(0.05)]
            )

            ModernStatCard(
                title: "Clientes",
                value: "\(viewModel.totalClientes)",
                icon: "person.2.fill",
                iconColor: .orange,
                gradientColors: [Color.orange.opacity(0.15), Color.orange.opacity(0.05)]
            )

            ModernStatCard(
                title: "Ingresos",
                value: String(format: "$%.2f", viewModel.totalMontoIngreso),
                icon: "arrow.up.right",
                iconColor: .green,
                gradientColors: [Color.green.opacity(0.15), Color.green.opacity(0.05)]
            )

            ModernStatCard(
                title: "Egresos",
                value: String(format: "$%.2f", viewModel.totalMontoEgreso),
                icon: "arrow.down.left",
                iconColor: .red,
                gradientColors: [Color.red.opacity(0.15), Color.red.opacity(0.05)]
            )

            ModernStatCard(
                title: "Descuentos",
                value: String(format: "$%.2f", viewModel.finalDescuento),
                icon: "tag.fill",
                iconColor: .purple,
                gradientColors: [Color.purple.opacity(0.15), Color.purple.opacity(0.05)]
            )

            ModernStatCard(
                title: "N. Crédito",
                value: String(format: "$%.2f", viewModel.totalMontoNotaCredito),
                icon: "creditcard.fill",
                iconColor: .teal,
                gradientColors: [Color.teal.opacity(0.15), Color.teal.opacity(0.05)]
            )

            ModernStatCard(
                title: "Total Factura Mes",
                value: String(format: "$%.2f", viewModel.totalFacturaDelMes),
                icon: "calendar",
                iconColor: .blue,
                gradientColors: [Color.blue.opacity(0.15), Color.blue.opacity(0.05)]
            )

            ModernStatCard(
                title: "Trans. Caja Grupo",
                value: "\(viewModel.totalTransaccionCajaGrupo)",
                icon: "person.3.fill",
                iconColor: .indigo,
                gradientColors: [Color.indigo.opacity(0.15), Color.indigo.opacity(0.05)]
            )
        }
    }

    // MARK: - CHARTS SECTION

    private var chartsSection: some View {
        VStack(spacing: 20) {
            ModernChartCard(title: "Ventas por Área", icon: "chart.bar.fill", iconColor: .blue) {
                Chart(viewModel.salesByAreaForChart) { item in
                    BarMark(
                        x: .value("Ventas", item.monto),
                        y: .value("Área", item.nombre.trimmingCharacters(in: .whitespaces))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                }
                .frame(height: 240)
            }

            ModernChartCard(title: "Ventas por Hora", icon: "clock.fill", iconColor: .orange) {
                Chart(viewModel.salesByHourForChart) { item in
                    BarMark(
                        x: .value("Hora", item.hour),
                        y: .value("Ventas", item.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .orange.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(8)
                }
                .frame(height: 240)
            }

            ModernChartCard(title: "Ventas por Caja", icon: "square.grid.2x2.fill", iconColor: .teal) {
                Chart(viewModel.allCashRegistersForChart.sorted(by: { $0.monto > $1.monto })) { register in
                    BarMark(
                        x: .value("Monto", register.monto),
                        y: .value("Caja", register.nombre)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.teal, .teal.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                    .annotation(position: .trailing, alignment: .leading) {
                        HStack(spacing: 4) {
                            Text(String(format: "$%.2f", register.monto))
                                .font(.system(size: 11, weight: .semibold))
                            Text("(\(register.transacciones))")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 300)
            }
        }
    }

    // MARK: - DETAILS SECTION

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "list.bullet.rectangle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.blue)
                Text("Detalle por Área y Caja")
                    .font(.system(size: 20, weight: .bold))
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

    // MARK: - TOOLBAR BUTTONS

    private var shareButton: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            capturedImage = dashboardContent.asImage(size: CGSize(width: UIScreen.main.bounds.width, height: contentHeight))
            isShowingShareSheet = true
        }) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .semibold))
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                )
        }
    }

    private var proactiveAssistantButton: some View {
        NavigationLink(destination: ProactiveAssistantView()) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.accentColor)
            }
        }
    }

    // MARK: - HELPERS

    private func setupRefreshTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if refreshCountdown > 0 {
                refreshCountdown -= 1
            } else {
                refreshCountdown = refreshInterval
            }
        }
    }
}

// MARK: - COMPONENTES UI ULTRA MODERNOS

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
                    .font(.system(size: 20, weight: .semibold))
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
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(iconColor.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
        .scaleEffect(isPressed ? 0.97 : 1.0)
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
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.15))
                    )

                Text(title)
                    .font(.system(size: 18, weight: .bold))

                Spacer()
            }

            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
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
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "desktopcomputer")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(areaData.nombre.trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)

                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                                Text("$\(areaData.totalMonto, specifier: "%.2f")")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.green)
                            }

                            HStack(spacing: 4) {
                                Image(systemName: "arrow.left.arrow.right.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Text("\(areaData.totalTransacciones)")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: expanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(expanded ? .blue : .secondary)
                }
                .padding(18)
            }
            .buttonStyle(PlainButtonStyle())

            if expanded {
                Divider()
                    .padding(.horizontal, 18)

                VStack(alignment: .leading, spacing: 10) {
                    if areaData.cajas.isEmpty {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                            Text("No hay cajas registradas")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 18)
                    } else {
                        ForEach(areaData.cajas.values.sorted(by: { $0.monto > $1.monto })) { registerDetail in
                            ModernCashRegisterRow(registerDetail: registerDetail)
                        }
                    }
                }
                .padding(.vertical, 10)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(expanded ? Color.blue.opacity(0.2) : Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(expanded ? 0.06 : 0.03), radius: expanded ? 10 : 6, x: 0, y: expanded ? 5 : 3)
    }
}

struct ModernCashRegisterRow: View {
    let registerDetail: CashRegisterDetail

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "point.3.connected.trianglepath.fill")
                .font(.system(size: 16))
                .foregroundColor(.teal)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.teal.opacity(0.1))
                )

            Text(registerDetail.nombre.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)

            Spacer()

            HStack(spacing: 8) {
                Text("\(registerDetail.transacciones)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.secondary.opacity(0.7))
                    )

                Text(String(format: "$%.2f", registerDetail.monto))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.teal.opacity(0.03))
        )
        .padding(.horizontal, 18)
    }
}

struct DashboardEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))

            Text("No hay datos disponibles")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.secondary)

            Text("Los detalles aparecerán aquí cuando haya información")
                .font(.system(size: 14))
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - PREVIEW

struct DashboardScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardScreen()
                .environmentObject(SettingsManager.shared)
        }
    }
}
