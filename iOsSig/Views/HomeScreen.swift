import SwiftUI
import Combine

struct HomeScreen: View {
    @EnvironmentObject var settings: SettingsManager
    @StateObject private var viewModel = HomeViewModel() // Integrate HomeViewModel
    
    let version: String
    let requestCode: String
    
    var body: some View {
        NavigationView { // Added NavigationView for better structure
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    if viewModel.isLoading {
                        ProgressView("Cargando datos...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .red))
                            .scaleEffect(1.2)
                            .padding(.vertical, 50)
                    } else if let error = viewModel.error {
                        ErrorView(errorMessage: error) {
                            viewModel.fetchSalesData() // Retry action
                        }
                    } else {
                        summaryCards
                    }
                    
                    infoOverlay
                }
                .padding(.top)
            }
            .background(Color.white.ignoresSafeArea()) // Clean background
            .navigationTitle("")
            .navigationBarHidden(true)
            .refreshable { // Add pull-to-refresh
                viewModel.fetchSalesData()
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image("logocmpc")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
        }
    }
    
    private var summaryCards: some View {
        VStack(spacing: 15) {
            Text("Resumen de Ventas")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            HStack {
                SummaryCard(title: "Monto Final", value: viewModel.totalMontoFinal, format: .currency)
                SummaryCard(title: "Transacciones", value: Double(viewModel.totalTransacciones), format: .number)
            }
            HStack {
                SummaryCard(title: "Facturas", value: Double(viewModel.totalFacturas), format: .number)
                SummaryCard(title: "Ingresos", value: viewModel.totalMontoIngreso, format: .currency)
            }
            HStack {
                SummaryCard(title: "Egresos", value: viewModel.totalMontoEgreso, format: .currency)
                SummaryCard(title: "Notas Crédito", value: viewModel.totalNotasCredito, format: .currency)
            }
        }
        .padding(.horizontal)
    }
    
    private var infoOverlay: some View {
        VStack {
            Spacer() // Pushes content to the top
            HStack {
                Spacer() // Pushes content to the right
                VStack(alignment: .trailing, spacing: 4) {
                    Text("CITYMALL DAVID")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    infoText("Licencia: \(requestCode)", size: .caption2)
                    infoText("Device: \(settings.userRole.rawValue)", size: .caption2)
                    infoText("Version: \(version)", size: .caption2)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 10)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func infoText(_ text: String, size: Font) -> some View {
        Text(text)
            .font(size)
            .foregroundColor(.gray)
    }
}

// MARK: - Sub-Views

struct SummaryCard: View {
    let title: String
    let value: Double
    let format: ValueFormat
    
    enum ValueFormat {
        case currency
        case number
    }
    
    var formattedValue: String {
        switch format {
        case .currency:
            return value.formatted(.currency(code: "USD")) // Assuming USD, adjust as needed
        case .number:
            return String(format: "%.0f", value)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(formattedValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ErrorView: View {
    let errorMessage: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Error al cargar datos")
                .font(.headline)
            Text(errorMessage)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button("Reintentar") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

// MARK: - Preview

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(version: "1.0", requestCode: "ABC-123")
            .environmentObject(SettingsManager.shared)
    }
}

