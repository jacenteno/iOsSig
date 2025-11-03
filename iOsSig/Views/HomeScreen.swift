
import SwiftUI
import Combine


struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var settings: SettingsManager
    
    let version: String
    let requestCode: String
    @Binding var showSettings: Bool
   
    @State private var showError: Bool = false // State to control ErrorView presentation
    
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        let role = settings.userRole
        let store=settings.$companyName
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                        .padding(.horizontal)
                    headerUsuario
                        .padding(.horizontal)
                    headerStore
                        .padding(.horizontal)
                    
                    if role.hasPermission("VIEW_DASHBOARD") {
                        if viewModel.isLoading {
                            ProgressView("Cargando...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                .scaleEffect(1.2)
                                .padding(.vertical, 50)
                        } else if let error = viewModel.error {
                            // Set showError to true to present the ErrorView
                            // The ErrorView will handle its own dismissal after a timeout
                            // or if the user taps retry.
                            Color.clear.onAppear {
                                showError = true
                            }
                        } else {
                            summaryHeaderSection.padding(.horizontal)
                            summaryGrid
                                .padding(.horizontal)
                        }
                        
                    }
                    
                    
                    Spacer() // Pushes the info overlay to the bottom
                    
                    infoOverlay
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .onAppear {
                viewModel.fetchSalesData()
            }
            .sheet(isPresented: $showError) {
                ErrorView(errorMessage: viewModel.error ?? "Error desconocido", retryAction: { viewModel.fetchSalesData() }, isShowingError: $showError, showSettings: $showSettings)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Resumen de Ventas de hoy")
            .navigationBarTitleDisplayMode(.inline)

            .refreshable {
                viewModel.fetchSalesData()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use stack style for a more standard appearance
    }
    
    private var headerSection: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Bienvenido")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
              
            
            }
           // Spacer()
            // You can add a settings button or other actions here if needed
        }
    }
    
    private var headerUsuario: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                infoText("Usuario: \(settings.userRole)", size: .caption2)
           
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
           
        }
    }
    private var headerStore: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                infoText("Tienda: \(settings.companyName)", size: .caption2)
           
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            
           
        }
    }
    
    
    private var summaryHeaderSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Resumen de Ventas de Hoy")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var summaryGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            SummaryCard(title: "Total Final hoy ", value: viewModel.totalMontoFinal, icon: "dollarsign.circle.fill", format: .currency, color: .green)
            SummaryCard(title: "Transacciones", value: Double(viewModel.totalTransacciones), icon: "arrow.2.squarepath", format: .number, color: .blue)
            SummaryCard(title: "Tickets", value: Double(viewModel.totalTickets), icon: "doc.text.fill", format: .number, color: .orange)
            SummaryCard(title: "Ventas del Mes", value: viewModel.totalFacturaDelMes, icon: "calendar", format: .currency, color: .purple)
            SummaryCard(title: "Total Ctes. CityPuntos ", value: Double(viewModel.totalClientes), icon: "person.2.fill", format: .number, color: .pink)
            SummaryCard(title: "Ingresos", value: viewModel.totalMontoIngreso, icon: "arrow.up.right.circle.fill", format: .currency, color: .cyan)
            SummaryCard(title: "Egresos", value: viewModel.totalMontoEgreso, icon: "arrow.down.left.circle.fill", format: .currency, color: .red)
            SummaryCard(title: "Notas Crédito", value: viewModel.totalMontoNotaCredito, icon: "creditcard.fill", format: .currency, color: .gray)
        }
    }
    
    private var infoOverlay: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("iOS App")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            infoText("Licencia: \(requestCode)", size: .caption2)
            infoText("Version: \(version)", size: .caption2)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }
    
    private func infoText(_ text: String, size: Font) -> some View {
        Text(text)
            .font(size)
            .foregroundColor(.gray)
    }
}

struct SummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let format: ValueFormat
    let color: Color
    
    enum ValueFormat {
        case currency
        case number
    }
    
    var formattedValue: String {
        switch format {
        case .currency:
            // Format currency with locale-specific settings
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
                .minimumScaleFactor(0.8) // Allows text to shrink
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}


struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(version: "1.0.0", requestCode: "XYZ-789", showSettings: .constant(false))
            .environmentObject(SettingsManager.shared)
    }
}

