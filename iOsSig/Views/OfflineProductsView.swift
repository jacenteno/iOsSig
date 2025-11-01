import SwiftUI

struct OfflineProductsView: View {
    @StateObject private var viewModel = OfflineProductsViewModel()

    var body: some View {
        VStack {
            SearchBarView(text: $viewModel.searchText, prompt: "Buscar por código, descripción...")

            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView()
                Spacer()
            } else if viewModel.products.isEmpty {
                // Muestra el EmptyState solo si no se está buscando activamente
                if viewModel.searchText.isEmpty {
                    EmptyStateView(systemImage: "tray.fill", message: "No hay productos locales. Sincronice los productos para poder consultarlos sin conexión.")
                } else {
                    EmptyStateView(systemImage: "magnifyingglass", message: "No se encontraron productos para \"\(viewModel.searchText)\".")
                }
            } else {
                List(viewModel.products) { product in
                    ProductRow(product: product)
                }
            }
        }
        .navigationTitle("Consulta Offline")
        .onAppear(perform: viewModel.onAppear)
    }
}

private struct ProductRow: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.desproducto ?? "Sin descripción")
                .font(.headline)
            
            Text("Departamento: \(product.nombre_departamento ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                VStack(alignment: .leading) {
                    Text("Código")
                        .font(.caption2).foregroundColor(.secondary)
                    Text(product.codproducto ?? "S/C")
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Referencia")
                        .font(.caption2).foregroundColor(.secondary)
                    Text(product.referencia ?? "N/A")
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Bodega")
                        .font(.caption2).foregroundColor(.secondary)
                    Text(product.codbodega ?? "N/A")
                }
            }
            .font(.caption)

            if let barcode = product.codigobarra, !barcode.isEmpty {
                HStack {
                    Image(systemName: "barcode")
                    Text(barcode)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Divider()

            HStack {
                VStack(alignment: .leading) {
                    Text("Existencia")
                        .font(.caption2).foregroundColor(.secondary)
                    Text("\(product.existencias ?? 0, specifier: "%.2f")")
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Últ. Costo")
                        .font(.caption2).foregroundColor(.secondary)
                    Text("$\(product.ultcosto ?? 0, specifier: "%.2f")")
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Precio Venta")
                        .font(.caption2).foregroundColor(.secondary)
                    Text("$\(product.preciodeventa ?? 0, specifier: "%.2f")")
                        .fontWeight(.bold)
                }
            }
            .font(.footnote)
        }
        .padding(.vertical, 8)
    }
}


#Preview {
    NavigationView {
        OfflineProductsView()
    }
}
