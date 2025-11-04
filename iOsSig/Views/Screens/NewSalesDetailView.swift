import SwiftUI

struct NewSalesDetailView: View {
    let sales: Ventas?

    var body: some View {
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
                Image(systemName: "chart.bar.xaxis")
                    .foregroundColor(.accentColor)
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
                Image(systemName: "arrow.down.right.circle.fill")
                    .foregroundColor(.accentColor)
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
