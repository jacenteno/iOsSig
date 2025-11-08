import SwiftUI
import Charts

struct HomeScreen: View {
    @StateObject private var viewModel = HomeScreenViewModel()
    @EnvironmentObject var settings: SettingsManager
    
    let version: String
    let requestCode: String
    @Binding var showSettings: Bool
    
    @State private var showError: Bool = false
    @State private var cardsAppeared = false
    @State private var headerAppeared = false
    
    var body: some View {
        ZStack {
            // FONDO GRADIENTE MODERNO
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    Color.blue.opacity(0.05),
                    Color.green.opacity(0.03)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // HEADER CON ANIMACIÓN
                    headerSection
                        .padding(.horizontal)
                        .opacity(headerAppeared ? 1 : 0)
                        .offset(y: headerAppeared ? 0 : -30)
                        .scaleEffect(headerAppeared ? 1 : 0.9)
                    
                    // TARJETA DE USUARIO
                    userInfoCard
                        .padding(.horizontal)
                        .opacity(headerAppeared ? 1 : 0)
                        .offset(y: headerAppeared ? 0 : 20)
                    
                    // CONTENIDO PRINCIPAL
                    // if settings.userRole.hasPermission("VIEW_DASHBOARD") {
                    if settings.hasPermission("VIEW_DASHBOARD") {
                        dashboardContent
                    }
                    
                    Spacer(minLength: 40)
                    
                    // VERSIÓN Y CÓDIGO
                    appInfoFooter
                        .padding(.horizontal)
                }
                .padding(.vertical, 20)
            }
            .refreshable {
                viewModel.fetchData()
            }
        }
        .onAppear {
            viewModel.fetchData()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                headerAppeared = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                cardsAppeared = true
            }
        }
        .sheet(isPresented: $showError) {
            ErrorView(
                errorMessage: viewModel.error ?? "Error desconocido",
                retryAction: { viewModel.fetchData() },
                isShowingError: $showError,
                showSettings: $showSettings
            )
        }
    }
    
    // MARK: - HEADER SECTION
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(getGreeting())
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(settings.companyName)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer()
            
            // ICONO ANIMADO
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.accentColor, .accentColor.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .symbolEffect(.pulse, options: .repeating)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - USER INFO CARD
    private var userInfoCard: some View {
        HStack(spacing: 16) {
            // AVATAR MEJORADO
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 64, height: 64)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.accentColor.opacity(0.2), .accentColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.accentColor)
                    .symbolRenderingMode(.hierarchical)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(settings.userRole.rawValue.capitalized)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                        .symbolRenderingMode(.multicolor)
                    
                    Text("Acceso Verificado")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.6))
                .symbolRenderingMode(.hierarchical)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - DASHBOARD CONTENT
    @ViewBuilder
    private var dashboardContent: some View {
        if viewModel.isLoading {
            loadingView
        } else if viewModel.error != nil {
            Color.clear.onAppear { showError = true }
        } else {
            VStack(spacing: 20) {
                // TARJETA DESTACADA
                if settings.hasPermission("VER_VENTA_HOME") {
                    FeaturedSummaryCard(
                        title: "Ventas de Hoy",
                        value: viewModel.totalMontoFinal,
                        icon: "dollarsign.circle.fill",
                        format: .currency,
                        primaryColor: .green,
                        secondaryColor: .mint
                    )
                    .padding(.horizontal)
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 30)
                }
                
                if !viewModel.salesByHourForChart.isEmpty {
                    FinancialChartView(data: viewModel.salesByHourForChart)
                }

                // RESUMEN DE ORDENES
                OrderSummaryCard(
                    pendingCount: viewModel.pendingOrderCount,
                    processingCount: viewModel.processingOrderCount
                )
                .padding(.horizontal)
                .opacity(cardsAppeared ? 1 : 0)
                .offset(y: cardsAppeared ? 0 : 30)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: cardsAppeared)
                
                // GRID DE ESTADÍSTICAS
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ModernSummaryCard(
                        title: "Clientes CityPuntos",
                        value: Double(viewModel.totalClientes),
                        icon: "person.2.fill",
                        format: .number,
                        color: .pink
                    )
                    
                    ModernSummaryCard(
                        title: "Pendiente Recepción",
                        value: Double(viewModel.receptionPendingCount),
                        icon: "archivebox.fill",
                        format: .number,
                        color: .indigo
                    )
                }
                .padding(.horizontal)
                .opacity(cardsAppeared ? 1 : 0)
                .offset(y: cardsAppeared ? 0 : 30)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: cardsAppeared)
                
                // OPERADORES
                if !viewModel.operatorSummary.isEmpty {
                    OperatorSummaryCard(summary: viewModel.operatorSummary)
                        .padding(.horizontal)
                        .opacity(cardsAppeared ? 1 : 0)
                        .offset(y: cardsAppeared ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: cardsAppeared)
                }
            }
        }
    }
    
    // MARK: - LOADING VIEW
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
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
    
    // MARK: - APP INFO FOOTER
    private var appInfoFooter: some View {
        VStack(spacing: 16) {
            Divider()
                .opacity(0.3)
            
            HStack(spacing: 20) {
                Label("iOS Application", systemImage: "apps.iphone")
                    .font(.system(size: 14, weight: .medium))
                
                Divider()
                    .frame(height: 20)
                
                HStack(spacing: 6) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 11))
                    Text(requestCode)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                }
                
                Divider()
                    .frame(height: 20)
                
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 11))
                    Text("v\(version)")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - HELPERS
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Buenos días 🌅"
        case 12..<18: return "Buenas tardes ☀️"
        default: return "Buenas noches 🌙"
        }
    }
}

// MARK: - TARJETAS MEJORADAS

struct FeaturedSummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let format: SummaryValueFormat
    let primaryColor: Color
    let secondaryColor: Color
    
    @State private var isPressed = false
    
    var formattedValue: String {
        switch format {
        case .currency:
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
        case .number:
            return String(format: "%.0f", value)
        }
    }
    
    var body: some View {
        ZStack {
            // FONDO GRADIENTE
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // EFECTO DE BRILLO
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.2), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    // ICONO
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.25))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .symbolRenderingMode(.hierarchical)
                    }
                    
                    Spacer()
                    
                    // CHIP "HOY"
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .bold))
                        Text("Hoy")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.2))
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                    
                    Text(formattedValue)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
            .padding(24)
        }
        .frame(height: 180)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .shadow(color: primaryColor.opacity(0.4), radius: 20, x: 0, y: 10)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

struct ModernSummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let format: SummaryValueFormat
    let color: Color
    
    @State private var isPressed = false
    
    var formattedValue: String {
        switch format {
        case .currency:
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
        case .number:
            return String(format: "%.0f", value)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ICONO
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.15), color.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
                    .symbolRenderingMode(.hierarchical)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedValue)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
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

struct OrderSummaryCard: View {
    let pendingCount: Int
    let processingCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // HEADER
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.15), Color.orange.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.orange)
                        .symbolRenderingMode(.hierarchical)
                }
                
                Text("Solicitudes a Bodega")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // CONTADORES
            HStack(spacing: 16) {
                // PENDIENTES
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "clock.fill")
                            .font(.system(size: 17))
                            .foregroundColor(.orange)
                            .symbolRenderingMode(.hierarchical)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(pendingCount)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Pendientes")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                
                // PROCESANDO
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "arrow.2.circlepath")
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                            .symbolRenderingMode(.hierarchical)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(processingCount)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Procesando")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
            }
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

struct OperatorSummaryCard: View {
    let summary: [OperatorOrderSummary]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // HEADER
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.15), Color.purple.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.purple)
                        .symbolRenderingMode(.hierarchical)
                }
                
                Text("Resumen por Operador")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // LISTA DE OPERADORES
            LazyVStack(spacing: 0) {
                ForEach(summary) { item in
                    HStack(spacing: 14) {
                        // AVATAR
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.accentColor.opacity(0.2), .accentColor.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            
                            Text(String(item.username.prefix(1)).uppercased())
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.accentColor)
                        }
                        
                        // INFO
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.username)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.orange)
                                    Text("\(item.pendingCount)")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.2.circlepath")
                                        .font(.system(size: 11))
                                        .foregroundColor(.blue)
                                    Text("\(item.processingCount)")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .padding(.vertical, 12)
                    
                    if item.id != summary.last?.id {
                        Divider()
                            .padding(.leading, 58)
                    }
                }
            }
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

struct FinancialChartView: View {
    let data: [HomeScreenViewModel.ChartableSalesByHour]
    
    private func colorFor(index: Int) -> Color {
        if index == 0 {
            return .blue // Default for first element
        }
        if data[index].amount > data[index - 1].amount {
            return .blue // Rise
        } else {
            return .red // Fall
        }
    }
    
    var body: some View {
        VStack {
            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    LineMark(
                        x: .value("Hour", item.hour),
                        y: .value("Sales", item.amount)
                    )
                    .foregroundStyle(colorFor(index: index))
                    
                    if item.amount < 0 { // Assuming cutoff is 0
                        AreaMark(
                            x: .value("Hour", item.hour),
                            yStart: .value("Zero", 0),
                            yEnd: .value("Sales", item.amount)
                        )
                        .foregroundStyle(Color.red.opacity(0.3))
                    }
                }
            }
            .chartYScale(domain: .automatic)
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel().font(.system(size: 10))
                }
            }
            .padding()
            .background(Color.black)
            .cornerRadius(10)
        }
        .padding()
    }
}

// MARK: - PREVIEWS
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(version: "2.0.0", requestCode: "ABC-123", showSettings: .constant(false))
            .environmentObject(SettingsManager.shared)
    }
}
