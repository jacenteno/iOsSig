import Charts
import SwiftUI

struct NewSalesDetailView: View {
  let sales: Ventas?
  @EnvironmentObject var settings: SettingsManager

  // Computed property to transform sales data for the new chart
  private var chartData: [SalesDataPoint] {
    guard let sales = sales, case .listaVentas(let ventas) = sales else {
      return []
    }

    // Group by month/year and sum ventas and salidas
    let groupedData = Dictionary(grouping: ventas, by: { $0.keyAnnoMes })
      .mapValues { salesInMonth -> (sales: Double, returns: Double) in
        let totalSales = salesInMonth.reduce(0) { $0 + Double($1.ventas) }
        let totalReturns = salesInMonth.reduce(0) { $0 + Double($1.salidas) }
        return (sales: totalSales, returns: totalReturns)
      }

    // Map to SalesDataPoint array
    return groupedData.map { key, totals in
      // Create a cleaner label for the chart
      let labelParts = key.split(separator: "/")
      let month = labelParts.first ?? ""
      let year = labelParts.count > 1 ? String(labelParts[1].suffix(2)) : ""
      let label = "\(month)/\(year)"
      return SalesDataPoint(label: label, sales: totals.sales, returns: totals.returns)
    }.sorted { $0.label < $1.label }  // Sort chronologically
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        // Add the new grouped bar chart view if data exists
        if !chartData.isEmpty {
          SalesHistoryChartView(
            data: chartData,
            salesColor: Color(hex: settings.accentColor) ?? .blue,
            returnsColor: .red
          )
        }

        // Existing list of sales cards
        if let sales = sales {
          switch sales {
          case .listaVentas(let ventas):
            LazyVStack(spacing: 12) {
              ForEach(ventas, id: \.keyAnnoMes) { venta in
                NewSaleDetailCard(venta: venta)
              }
            }
            .padding()
          case .mensaje(let mensaje):
            Text(mensaje)
              .font(.headline)
              .foregroundColor(.secondary)
              .padding()
          }
        } else {
          Text("No hay información de ventas.")
            .font(.headline)
            .foregroundColor(.secondary)
            .padding()
        }
      }
    }
    .background(Color(.systemGroupedBackground))
  }
}

struct NewSaleDetailCard: View {
  let venta: VentaHistorial

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "calendar")
          .foregroundColor(.accentColor)
        Text("Fecha:")
          .font(.subheadline)
          .foregroundColor(.secondary)
        Spacer()
        Text(venta.titulo)
          .font(.subheadline)
          .fontWeight(.medium)
      }

      Divider()

      HStack {
        Image(systemName: "arrow.up.right.circle.fill")
          .foregroundColor(.green)
        Text("Ventas:")
          .font(.subheadline)
          .foregroundColor(.secondary)
        Spacer()
        Text("\(venta.ventas)")
          .font(.subheadline)
          .fontWeight(.medium)
      }

      Divider()

      HStack {
        Image(systemName: "arrow.down.left.circle.fill")
          .foregroundColor(.red)
        Text("Salidas:")
          .font(.subheadline)
          .foregroundColor(.secondary)
        Spacer()
        Text("\(venta.salidas)")
          .font(.subheadline)
          .fontWeight(.medium)
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
  }
}
