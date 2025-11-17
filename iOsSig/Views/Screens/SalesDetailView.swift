import Charts
import SwiftUI

struct SalesDetailView: View {
  let venta: Venta
  @EnvironmentObject var settings: SettingsManager

  // Computed property to transform sales data for the chart
  private var chartData: [ChartDataPoint] {
    venta.ventasMensuales.map { ventaMensual in
      let label = "\(ventaMensual.mes)/\(String(ventaMensual.anio).suffix(2))"
      return ChartDataPoint(label: label, value: Double(ventaMensual.totalUnidades))
    }
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        // Show the chart if there is data, otherwise show an empty state message.
        if !chartData.isEmpty {
          HistoryChartView(
            data: chartData,
            title: "Unidades Vendidas (Mes)",
            accentColor: Color(hex: settings.accentColor) ?? .accentColor
          )
        } else {
          VStack {
            EmptyStateView(
              systemImage: "chart.bar.xaxis.ascending",
              message: "No hay datos de ventas mensuales para mostrar en el gráfico."
            )
          }
          .padding()
          .background(Color(.systemBackground))
          .cornerRadius(16)
          .padding(.horizontal)
        }

        // Existing content
        VStack(alignment: .leading, spacing: 16) {
          headerView
          Divider()
          summaryView
          Divider()
          monthlySalesList
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
      }
    }
    .background(Color(.systemGroupedBackground))  // Use a system background
  }

  private var headerView: some View {
    HStack {
      Image(systemName: "chart.bar.fill")
        .font(.title2)
        .foregroundColor(Color(hex: settings.accentColor) ?? .accentColor)
      Text("Resumen de Ventas")
        .font(.title2)
        .fontWeight(.bold)
    }
  }

  private var summaryView: some View {
    HStack(spacing: 16) {
      SummaryCard(
        title: "Total Vendido",
        value: Double(venta.totalVendido),
        icon: "cart.fill",
        format: SummaryValueFormat.number,
        color: Color(hex: settings.accentColor) ?? .blue
      )
      SummaryCard(
        title: "Monto Total",
        value: Double(venta.totalMonto),
        icon: "dollarsign.circle.fill",
        format: SummaryValueFormat.currency,
        color: .green
      )
    }
  }

  private var monthlySalesList: some View {
    VStack(alignment: .leading) {
      Text("Detalle Mensual")
        .font(.headline)
        .padding(.bottom, 8)

      ForEach(venta.ventasMensuales) { ventaMensual in
        MonthlySaleRow(ventaMensual: ventaMensual)
      }
    }
  }
}

struct MonthlySaleRow: View {
  let ventaMensual: VentaMensual

  var body: some View {
    HStack {
      Text("\(ventaMensual.mes)/\(ventaMensual.anio)")
        .font(.headline)
      Spacer()
      VStack(alignment: .trailing) {
        Text("Cantidad: \(String(format: "%.0f", ventaMensual.totalUnidades))")
        Text("Monto: \(String(format: "$%.2f", ventaMensual.totalMontos))")
      }
      .font(.subheadline)
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(12)
  }
}
