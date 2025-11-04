import SwiftUI

struct ProductDetailsButtons: View {
    let product: Product
    let codproducto: String
    let venta: Venta?
    let citymallProd: Resultado?
    let onNavigateToCambioPrecio: (String) -> Void

    @State private var isVentasActive = false
    @State private var isComprasActive = false
    @State private var isHacerPedidosActive = false
    @State private var isEtiquetaActive = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                // Background NavigationLinks
                NavigationLink(destination: VentasScreen(), isActive: $isVentasActive) { EmptyView() }
                NavigationLink(destination: ComprasScreen(), isActive: $isComprasActive) { EmptyView() }
                NavigationLink(destination: HacerPedidosScreen(), isActive: $isHacerPedidosActive) { EmptyView() }
                NavigationLink(destination: EtiquetaScreen(product: product), isActive: $isEtiquetaActive) { EmptyView() }

                // Visible Buttons
                Button(action: { onNavigateToCambioPrecio(codproducto) }) {
                    VStack {
                        Image(systemName: "square.and.pencil").font(.title2)
                        Text("C.Precio").font(.caption)
                    }
                }

                Button(action: { isVentasActive = true }) {
                    VStack {
                        Image(systemName: "chart.bar").font(.title2)
                        Text("Ventas").font(.caption)
                    }
                }

                Button(action: { isComprasActive = true }) {
                    VStack {
                        Image(systemName: "cart").font(.title2)
                        Text("Compras").font(.caption)
                    }
                }

                Button(action: { isHacerPedidosActive = true }) {
                    VStack {
                        Image(systemName: "plus.circle").font(.title2)
                        Text("Pedir").font(.caption)
                    }
                }

                Button(action: { isEtiquetaActive = true }) {
                    VStack {
                        Image(systemName: "tag").font(.title2)
                        Text("Etiqueta").font(.caption)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}
