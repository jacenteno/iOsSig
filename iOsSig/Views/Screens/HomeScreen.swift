import SwiftUI
import Combine

struct HomeScreen: View {
    @StateObject private var viewModel = HomeScreenViewModel()
    @EnvironmentObject var settings: SettingsManager
    
    let version: String
    let requestCode: String
    @Binding var showSettings: Bool
   
    @State private var showError: Bool = false
    @State private var cardsAppeared = false
    @State private var headerAppeared = false
    
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        let role = settings.userRole
        let store = settings.$companyName
        
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color.green.opacity(0.03),
                    Color.blue.opacity(0.04)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                        .padding(.horizontal)
                        .opacity(headerAppeared ? 1 : 0)
                        .offset(y: headerAppeared ? 0 : -20)
                    
                    userInfoCard
                        .padding(.horizontal)
                        .opacity(headerAppeared ? 1 : 0)
                        .offset(y: headerAppeared ? 0 : 20)
                    
                    if role.hasPermission("VIEW_DASHBOARD") {
                        if viewModel.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Cargando datos...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if let error = viewModel.error {
                            Color.clear.onAppear {
                                showError = true
                            }
                        } else {
                            summarySection
                                .opacity(cardsAppeared ? 1 : 0)
                        }
                    }
                    
                    Spacer(minLength: 20)
                    
                    infoOverlay
                        .padding(.horizontal)
                        .padding(.bottom, 20)
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
            ErrorView(errorMessage: viewModel.error ?? "Error desconocido", retryAction: { viewModel.fetchData() }, isShowingError: $showError, showSettings: $showSettings)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(getCurrentGreeting())
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(settings.companyName)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    private var userInfoCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: 54, height: 54)
                
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(settings.userRole.rawValue.capitalized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.green)
                    Text("Acceso Verificado")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeaturedSummaryCard(
                title: "Ventas de Hoy",
                value: viewModel.totalMontoFinal,
                icon: "dollarsign.circle.fill",
                format: .currency,
                primaryColor: .green,
                secondaryColor: .cyan
            )
            .padding(.horizontal)

            OrderSummaryCard(
                pendingCount: viewModel.pendingOrderCount,
                processingCount: viewModel.processingOrderCount
            )
            .padding(.horizontal)

            if !viewModel.operatorSummary.isEmpty {
                OperatorSummaryCard(summary: viewModel.operatorSummary)
                    .padding(.horizontal)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ModernSummaryCard(
                    title: "Clientes CityPuntos",
                    value: Double(viewModel.totalClientes),
                    icon: "person.2.fill",
                    format: .number,
                    color: .pink
                )
                
                ModernSummaryCard(
                    title: "Pendiente de Recepción",
                    value: Double(viewModel.receptionPendingCount),
                    icon: "archivebox.fill",
                    format: .number,
                    color: .indigo
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var infoOverlay: some View {
        VStack(spacing: 14) {
            Divider()
                .opacity(0.5)
            
            VStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "apps.iphone")
                        .font(.system(size: 16))
                        .foregroundColor(.accentColor)
                    Text("iOS Application")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 5) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(requestCode)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    Circle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 3, height: 3)
                    
                    HStack(spacing: 5) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text("v\(version)")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private func getCurrentGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Buenos días 🌅"
        case 12..<18: return "Buenas tardes ☀️"
        default: return "Buenas noches 🌙"
        }
    }
}

// MARK: - Featured Summary Card
struct FeaturedSummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let format: SummaryValueFormat
    let primaryColor: Color
    let secondaryColor: Color
    
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
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [primaryColor, secondaryColor]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .white.opacity(0.15), location: 0),
                            .init(color: .clear, location: 0.3),
                            .init(color: .clear, location: 0.7),
                            .init(color: .black.opacity(0.1), location: 1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: icon)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .bold))
                        Text("Hoy")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.2))
                    )
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                    
                    Text(formattedValue)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(22)
        }
        .frame(height: 170)
        .shadow(color: primaryColor.opacity(0.35), radius: 20, x: 0, y: 12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Modern Summary Card
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
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.15), color.opacity(0.08)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                Spacer()
            }
            .padding(.bottom, 16)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(formattedValue)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
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

// MARK: - Order Summary Card
struct OrderSummaryCard: View {
    let pendingCount: Int
    let processingCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange.opacity(0.15), Color.orange.opacity(0.08)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.orange)
                }
                
                Text("Solicitudes a Bodega")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }

            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "clock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(pendingCount)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Pendientes")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemBackground))
                )
                
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "arrow.2.circlepath")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(processingCount)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Procesando")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemBackground))
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Operator Summary Card
struct OperatorSummaryCard: View {
    let summary: [OperatorOrderSummary]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple.opacity(0.15), Color.purple.opacity(0.08)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.purple)
                }
                
                Text("Resumen por Operador")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }

            VStack(spacing: 14) {
                ForEach(summary) { item in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                            
                            Text(String(item.username.prefix(1)).uppercased())
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.accentColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.username)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                HStack(spacing: 3) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.orange)
                                    Text("\(item.pendingCount)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack(spacing: 3) {
                                    Image(systemName: "arrow.2.circlepath")
                                        .font(.system(size: 10))
                                        .foregroundColor(.blue)
                                    Text("\(item.processingCount)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary.opacity(0.4))
                    }
                    .padding(.vertical, 8)
                    
                    if item.id != summary.last?.id {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(version: "1.0.0", requestCode: "XYZ-789", showSettings: .constant(false))
            .environmentObject(SettingsManager.shared)
    }
}
