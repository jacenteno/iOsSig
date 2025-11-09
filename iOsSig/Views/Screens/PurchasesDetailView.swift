import SwiftUI
import Charts

struct PurchasesDetailView: View {
    let citymallProd: Resultado?
    @EnvironmentObject var settings: SettingsManager

    // Computed property to process purchase history for the new chart
    private var chartData: [PurchaseDataPoint] {
        guard let comprasEnum = citymallProd?.compras,
              case .listaCompras(let compras) = comprasEnum else {
            return []
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"

        // Group purchases by month/year
        let groupedByMonth = Dictionary(grouping: compras) { compra -> Date in
            guard let date = dateFormatter.date(from: compra.fecmov) else {
                return Date.distantPast
            }
            let components = Calendar.current.dateComponents([.year, .month], from: date)
            return Calendar.current.date(from: components) ?? Date.distantPast
        }
        .filter { $0.key != Date.distantPast }

        // Sort keys to ensure chronological order
        let sortedKeys = groupedByMonth.keys.sorted()

        // Map the sorted data to PurchaseDataPoint array
        return sortedKeys.map { date in
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMM/yy"
            let label = monthFormatter.string(from: date)
            
            let comprasInMonth = groupedByMonth[date] ?? []
            let totalIn = comprasInMonth.reduce(0.0) { $0 + Double($1.cEnt ?? 0) }
            let totalOut = comprasInMonth.reduce(0.0) { $0 + Double($1.cSal ?? 0) }
            
            return PurchaseDataPoint(label: label, quantityIn: totalIn, quantityOut: totalOut)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Add the new grouped bar chart view if data exists
                if !chartData.isEmpty {
                    PurchasesHistoryChartView(
                        data: chartData,
                        inColor: .green,
                        outColor: .orange
                    )
                }

                // Existing content
                if let citymallProd = citymallProd {
                    switch citymallProd.compras {
                    case .listaCompras(let compras):
                        LazyVStack(spacing: 12) {
                            ForEach(compras, id: \.numdoc) { compra in
                                PurchaseDetailCard(compra: compra)
                            }
                        }
                        .padding()
                    case .mensaje(let mensaje):
                        Text(mensaje)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                    case nil:
                        Text("No hay información de compras.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                } else {
                    Text("No hay datos de compras.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct PurchaseDetailCard: View {
    let compra: CompraHistorial

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.accentColor)
                Text("Tipo: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(compra.tipo)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.accentColor)
                Text("Documento: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(compra.numdoc)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                Text("Fecha: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(compra.fecmov)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.accentColor)
                Text("Proveedor: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(compra.prov)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.accentColor)
                Text("Costo Unitario: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "$%.6f", compra.costou))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                Image(systemName: "dollarsign.square.fill")
                    .foregroundColor(.accentColor)
                Text("Costo Promedio: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "$%.6f", compra.costop))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                Image(systemName: "arrow.down.doc.fill")
                    .foregroundColor(.green)
                Text("Cantidad Entrada: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(compra.cEnt ?? 0)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                Image(systemName: "arrow.up.doc.fill")
                    .foregroundColor(.orange)
                Text("Cantidad Salida: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(compra.cSal ?? 0)")
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
