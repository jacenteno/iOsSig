import SwiftUI

struct PurchasesDetailView: View {
    let citymallProd: Resultado?

    var body: some View {
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
                    .foregroundColor(.accentColor)
                Text("Cantidad Entrada: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(compra.cEnt ?? 0)") // Handle optional cEnt
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                Image(systemName: "arrow.up.doc.fill")
                    .foregroundColor(.accentColor)
                Text("Cantidad Salida: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(compra.cSal ?? 0)") // Handle optional cSal
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
