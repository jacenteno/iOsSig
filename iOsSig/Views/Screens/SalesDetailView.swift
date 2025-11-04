import SwiftUI

struct SalesDetailView: View {
    let venta: Venta

    var body: some View {
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
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "chart.bar.fill")
                .font(.title2)
                .foregroundColor(.accentColor)
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
                color: .blue
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
            Text("Ventas Mensuales")
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
