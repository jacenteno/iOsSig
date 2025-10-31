import SwiftUI
import Charts // Requires iOS 16+

struct DashboardScreen: View {
    @EnvironmentObject var settings: SettingsManager
    @StateObject var viewModel = HomeViewModel()

    @State private var refreshCountdown: Int = 45
    private let refreshInterval: Int = 45
    @State private var showError: Bool = false // State to control ErrorView presentation

    init() {}

    var body: some View {
        NavigationView {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()

                if viewModel.isLoading && viewModel.ventaPorGrupoCaja.isEmpty {
                    ProgressView()
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
                                        VStack(alignment: .leading) {
                                            // The header is now handled by the standard navigation bar.
                
                                            // Stats Grid
                                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                                StatCardImproved(title: "Transacciones", value: String(viewModel.totalTransacciones), icon: "arrow.left.arrow.right", iconColor: .customOrange)
                                                StatCardImproved(title: "Total Tickets", value: String(viewModel.totalTickets), icon: "doc.text", iconColor: .customPrimary)
                                                StatCardImproved(title: "Ingresos", value: String(format: "$%.2f", viewModel.totalMontoIngreso), icon: "arrow.up.right", iconColor: .customGreen)
                                                StatCardImproved(title: "Egresos", value: String(format: "$%.2f", viewModel.totalMontoEgreso), icon: "arrow.down.left", iconColor: .customError)
                                                StatCardImproved(title: "Descuentos", value: String(format: "$%.2f", viewModel.finalDescuento), icon: "tag.fill", iconColor: .customDeepPurple)
                                                StatCardImproved(title: "N. Crédito", value: String(format: "$%.2f", viewModel.totalMontoNotaCredito), icon: "creditcard.fill", iconColor: .customTeal)
                                            }
                                            .padding(.horizontal)
                
                                            // Venta Final Card
                                            CardView(title: "Venta Final Neta", value: String(format: "$%.2f", viewModel.totalMontoFinal), icon: "dollarsign.circle.fill", iconColor: .customPinkRed)
                                                .padding(.horizontal)
                
                                            // Chart 1: Ventas por Área
                                            ChartCard(title: "Ventas por Área") {
                                                Chart(viewModel.salesByAreaForChart) { item in
                                                    BarMark(
                                                        x: .value("Ventas", item.monto),
                                                        y: .value("Área", item.nombre.trimmingCharacters(in: .whitespaces))
                                                    )
                                                    .foregroundStyle(by: .value("Área", item.nombre.trimmingCharacters(in: .whitespaces)))
                                                }
                                                .chartYAxis {
                                                    AxisMarks(position: .leading)
                                                }
                                                .chartLegend(.hidden)
                                                .frame(height: 200)
                                            }
                                            .padding(.horizontal)
                
                                            // Detalle por Área y Caja
                                            Text("Detalle por Área y Caja")
                                                .font(.title2)
                                                .padding(.horizontal)
                
                                            if viewModel.ventaPorGrupoCajaDetalle.isEmpty {
                                                Text("No hay detalles de ventas por área disponibles.")
                                                    .foregroundColor(.gray)
                                                    .padding(.horizontal)
                                            } else {
                                                ForEach(viewModel.ventaPorGrupoCajaDetalle.values.sorted(by: { $0.nombre < $1.nombre })) { areaData in
                                                    SalesAreaDetailCard(areaData: areaData)
                                                        .padding(.horizontal)
                                                }
                                            }
                                            ChartCard(title: "Ventas por Hora") {
                                                Chart(viewModel.salesByHourForChart) { item in
                                                    BarMark(
                                                        x: .value("Hora", item.hour),
                                                        y: .value("Ventas", item.amount)
                                                    )
                                                    .foregroundStyle(Color.customPrimary)
                                                }
                                                .chartXAxis {
                                                    AxisMarks(values: .automatic) { value in
                                                        AxisGridLine()
                                                        AxisTick()
                                                        AxisValueLabel {
                                                            if let hour = value.as(String.self) {
                                                                Text(hour)
                                                                    .rotationEffect(.degrees(-45))
                                                                    .offset(y: 10)
                                                            }
                                                        }
                                                    }
                                                }
                                                .frame(height: 250)
                                            }
                                            .padding(.horizontal)
                
                                            // New Chart: Ventas por Caja
                                            ChartCard(title: "Ventas por Caja") {
                                                Chart(viewModel.allCashRegistersForChart.sorted(by: { $0.monto > $1.monto })) { register in
                                                    BarMark(
                                                        x: .value("Monto", register.monto),
                                                        y: .value("Caja", register.nombre)
                                                    )
                                                    .foregroundStyle(Color.customPrimary)
                                                    .annotation(position: .trailing, alignment: .leading) {
                                                        HStack {
                                                            Text(String(format: "$%.2f", register.monto))
                                                                .font(.system(size: 4))
                                                                .foregroundColor(.primary)
                                                            Text("(\(register.transacciones) Tr.)")
                                                                .font(.system(size:4))
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                }
                                                .chartYAxis {
                                                    AxisMarks(position: .leading)
                                                }
                                                .chartLegend(.hidden)
                                                .frame(height: 250)
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                    .refreshable {
                                        // Allow user to pull-to-refresh
                                        viewModel.fetchSalesData()
                                        self.refreshCountdown = self.refreshInterval
                                    }
                                }
                            }
                            .sheet(isPresented: $showError) {
                                ErrorView(errorMessage: viewModel.error ?? "Error desconocido", retryAction: { viewModel.fetchSalesData() }, isShowingError: $showError)
                            }
                                        .navigationTitle("Dashboard")
                                    }                
        .onAppear {
            // The ViewModel now handles its own initial fetch
            setupRefreshTimer()
        }
    }

    private func setupRefreshTimer() {
        // This timer is purely for the UI countdown
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.refreshCountdown > 0 {
                self.refreshCountdown -= 1
            } else {
                // The ViewModel's timer will handle the fetch. We just reset the UI.
                self.refreshCountdown = self.refreshInterval
            }
        }
    }
}

// --- Helper Views --- 

struct StatCardImproved: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color

    var body: some View {
        CardView(title: title, value: value, icon: icon, iconColor: iconColor)
    }
}

struct CardView: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            HStack {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(iconColor)
                Spacer()
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(iconColor)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            content()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct SalesAreaDetailCard: View {
    let areaData: AreaDetail
    @State private var expanded: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(areaData.nombre)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    Text("Total: $\(areaData.totalMonto, specifier: "%.2f") (\(areaData.totalTransacciones) Tr.)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle()) // Make entire row tappable
            .onTapGesture {
                withAnimation { expanded.toggle() }
            }

            if expanded {
                Divider()
                VStack(alignment: .leading) {
                    if areaData.cajas.isEmpty {
                        Text("No hay cajas registradoras en esta área.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    } else {
                        ForEach(areaData.cajas.values.sorted(by: { $0.nombre < $1.nombre })) { registerDetail in
                            CashRegisterRow(registerDetail: registerDetail)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct CashRegisterRow: View {
    let registerDetail: CashRegisterDetail

    var body: some View {
        HStack {
            Text(registerDetail.nombre)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text("\(registerDetail.transacciones) Tr.")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("$\(registerDetail.monto, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
        .padding(.vertical, 4)
    }
}

extension Color {
    static let customPrimary = Color.red // Equivalent to colorScheme.primary in Kotlin
    static let customError = Color.red // Equivalent to colorScheme.error in Kotlin
    static let customOrange = Color(red: 0xFF / 255.0, green: 0xA0 / 255.0, blue: 0x00 / 255.0) // 0xFFFFA000
    static let customGreen = Color(red: 0x38 / 255.0, green: 0x8E / 255.0, blue: 0x3C / 255.0) // 0xFF388E3C
    static let customDeepPurple = Color(red: 0x5E / 255.0, green: 0x35 / 255.0, blue: 0xB1 / 255.0) // 0xFF5E35B1
    static let customTeal = Color(red: 0x00 / 255.0, green: 0x89 / 255.0, blue: 0x7B / 255.0) // 0xFF00897B
    static let customPinkRed = Color(red: 0xD8 / 255.0, green: 0x1B / 255.0, blue: 0x60 / 255.0) // 0xFFd81b60
}

struct DashboardScreen_Previews: PreviewProvider {
    static var previews: some View {
        DashboardScreen()
            .environmentObject(SettingsManager.shared)
    }
}
