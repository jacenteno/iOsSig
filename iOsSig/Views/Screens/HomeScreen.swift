import SwiftUI
import Combine

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
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
        
        NavigationView {
            ZStack {
                // Modern gradient background
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
                    viewModel.fetchSalesData()
                }
            }
            .onAppear {
                viewModel.fetchSalesData()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    headerAppeared = true
                }
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                    cardsAppeared = true
                }
            }
            .sheet(isPresented: $showError) {
                ErrorView(errorMessage: viewModel.error ?? "Error desconocido", retryAction: { viewModel.fetchSalesData() }, isShowingError: $showError, showSettings: $showSettings)
            }
            .navigationTitle("Resumen de Ventas")
            .navigationBarTitleDisplayMode(.inline)

        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bienvenido")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(getCurrentGreeting())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Animated icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green.opacity(0.2), Color.blue.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    private var userInfoCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // User avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                      //  Text(settings.userRole)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "storefront.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text(settings.companyName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Featured card - Total Final
            FeaturedSummaryCard(
                title: "Total Final Hoy",
                value: viewModel.totalMontoFinal,
                icon: "dollarsign.circle.fill",
                format: .currency,
                primaryColor: .green,
                secondaryColor: .cyan
            )
            .padding(.horizontal)
            
            // Grid header
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
                Text("Métricas del Día")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            
            // Grid of cards
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ModernSummaryCard(
                    title: "Transacciones",
                    value: Double(viewModel.totalTransacciones),
                    icon: "arrow.2.squarepath",
                    format: .number,
                    color: .blue
                )
                
                ModernSummaryCard(
                    title: "Tickets",
                    value: Double(viewModel.totalTickets),
                    icon: "doc.text.fill",
                    format: .number,
                    color: .orange
                )
                
                ModernSummaryCard(
                    title: "Ingresos",
                    value: viewModel.totalMontoIngreso,
                    icon: "arrow.up.right.circle.fill",
                    format: .currency,
                    color: .cyan
                )
                
                ModernSummaryCard(
                    title: "Egresos",
                    value: viewModel.totalMontoEgreso,
                    icon: "arrow.down.left.circle.fill",
                    format: .currency,
                    color: .red
                )
            }
            .padding(.horizontal)
            
            // Monthly section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar.circle.fill")
                        .font(.title3)
                        .foregroundColor(.purple)
                    Text("Resumen del Mes")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    MonthlyMetricCard(
                        title: "Ventas del Mes",
                        value: viewModel.totalFacturaDelMes,
                        icon: "calendar",
                        color: .purple
                    )
                    
                    MonthlyMetricCard(
                        title: "Clientes CityPuntos",
                        value: Double(viewModel.totalClientes),
                        icon: "person.2.fill",
                        color: .pink,
                        format: .number
                    )
                }
            }
            .padding(.horizontal)
            
            // Additional metrics
            VStack(spacing: 12) {
                AdditionalMetricRow(
                    title: "Notas de Crédito",
                    value: viewModel.totalMontoNotaCredito,
                    icon: "creditcard.fill",
                    color: .gray
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var infoOverlay: some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "apps.iphone")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("iOS App")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "key.fill")
                            .font(.caption2)
                        Text("Licencia: \(requestCode)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                            .font(.caption2)
                        Text("Versión: \(version)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground).opacity(0.5))
            )
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
                        gradient: Gradient(colors: [primaryColor.opacity(0.85), secondaryColor.opacity(0.75)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: primaryColor.opacity(0.3), radius: 20, x: 0, y: 10)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(formattedValue)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(24)
        }
        .frame(height: 160)
    }
}

// MARK: - Value Format (shared enum)
enum SummaryValueFormat {
    case currency
    case number
}

// MARK: - Legacy Summary Card (for backward compatibility)
struct SummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let format: SummaryValueFormat
    let color: Color
    
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(formattedValue)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(color.opacity(0.15))
                    )
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(formattedValue)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 130)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.1), color.opacity(0.05)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.15), lineWidth: 1)
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

// MARK: - Monthly Metric Card
struct MonthlyMetricCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    var format: SummaryValueFormat = .currency
    
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
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(formattedValue)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 110)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Additional Metric Row
struct AdditionalMetricRow: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    
    var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(formattedValue)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(version: "1.0.0", requestCode: "XYZ-789", showSettings: .constant(false))
            .environmentObject(SettingsManager.shared)
    }
}
