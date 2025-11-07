import SwiftUI

struct HacerPedidosScreen: View {
    @EnvironmentObject var cartManager: CartManager
    @StateObject private var viewModel = HacerPedidosViewModel()
    @State private var selection = Set<String>()
    @Environment(\.editMode) private var editMode

    private var isEditing: Bool {
        editMode?.wrappedValue == .active
    }

    var body: some View {
        ZStack {
            // 1. Background Gradient
            LinearGradient(
                colors: [Color(.systemBackground), Color.accentColor.opacity(0.03)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // 2. Content
            if cartManager.items.isEmpty {
                EmptyStateView(
                    systemImage: "cart.badge.questionmark",
                    message: "Tu pedido está vacío.\nAgrega productos para continuar."
                )
            } else {
                mainContentView
            }
        }
        .navigationTitle("Hacer Pedido")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // This is a valid use of ToolbarContentBuilder
            if !cartManager.items.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            // This is also a valid use of ViewBuilder
            if !cartManager.items.isEmpty {
                bottomBar
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.isSuccess ? "✓ Pedido Enviado" : "⚠️ Error"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if viewModel.isSuccess {
                        cartManager.clearCart()
                    }
                }
            )
        }
    }

    private var mainContentView: some View {
        List(selection: $selection) {
            ForEach(cartManager.items) { item in
                OrderItemRowView(item: item)
                    .tag(item.id)
            }
            .onDelete(perform: deleteItems)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .padding(.vertical, 4)
            )
        }
        .listStyle(.plain)
        .padding(.top, 10)
    }

    private var bottomBar: some View {
        VStack(spacing: 16) {
            totalsView
            
            if isEditing {
                editActionsView
            }
            
            actionButton
        }
        .padding()
        .background(.thinMaterial)
    }

    private var totalsView: some View {
        // Re-written with map and reduce, which is functionally identical but syntactically different
        let totalUnidades = cartManager.items.map(\.unidades).reduce(0, +)
        let totalCajas = cartManager.items.map(\.cajas).reduce(0, +)

        return VStack(spacing: 12) {
            HStack {
                Text("Total Unidades:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(totalUnidades)")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            HStack {
                Text("Total Cajas:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(totalCajas)")
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    private var editActionsView: some View {
        HStack {
            Button("Seleccionar Todo", action: selectAll)
                .buttonStyle(.bordered)
            
            Spacer()
            
            Button("Borrar (\(selection.count))", action: deleteSelection)
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(selection.isEmpty)
        }
    }

    private var actionButton: some View {
        Button(action: {
            Task {
                await viewModel.createOrder(cartManager: cartManager)
            }
        }) {
            HStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "paperplane.fill")
                    Text("Enviar Pedido")
                }
            }
            .fontWeight(.semibold)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if viewModel.isLoading || isEditing {
                        Color.gray.opacity(0.5)
                    } else {
                        Color.accentColor
                    }
                }
            )
            .cornerRadius(16)
            .shadow(
                color: (viewModel.isLoading || isEditing) ? .clear : .accentColor.opacity(0.4),
                radius: 10, x: 0, y: 5
            )
        }
        .disabled(viewModel.isLoading || isEditing)
    }

    // MARK: - Functions
    private func selectAll() {
        selection = Set(cartManager.items.map { $0.id })
    }

    private func deleteSelection() {
        withAnimation {
            selection.forEach { cartManager.removeItem(productID: $0) }
            selection.removeAll()
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let idsToDelete = offsets.map { cartManager.items[$0].id }
        withAnimation {
            idsToDelete.forEach { cartManager.removeItem(productID: $0) }
        }
    }
}

// MARK: - Order Item Row
struct OrderItemRowView: View {
    let item: OrderItem

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "shippingbox.fill")
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 35)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.desproducto ?? "N/A")
                    .font(.headline)
                    .lineLimit(2)
                
                Text(item.product.codproducto ?? "N/A")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("C: \(item.cajas)")
                Text("U: \(item.unidades)")
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#if DEBUG
struct HacerPedidosScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HacerPedidosScreen()
                .environmentObject(CartManager.sampleForPreview)
        }
    }
}

extension CartManager {
    static var sampleForPreview: CartManager {
        let manager = CartManager()
        
        // First sample product
        manager.addItem(product: Product.sample, unidades: 5, cajas: 1)
        
        // Second sample product, created cleanly
        let anotherProduct = Product(
            codcompania: 1, codbodega: "B02", coddep: 12, desproducto: "Otro Producto de Prueba Con un Nombre Muy Largo para ver como se corta", detalle: nil, codigobarra: "987654321", codproducto: "PROD-002", codproveedor: nil, referencia: "REF-002", nombre_departamento: "Hogar", ultcosto: 50.0, existencias: 200, ubicacion: nil, ofertas: nil, ucosto: nil, costofob: nil, indexproductos: 2, costooriginal: nil, preciodeventa: 79.99, fvencimiento: nil, ctacontable: nil, bloqueofacturacion: nil, gravadoexecto: nil, prcimpuestoventa: nil, nombre_lista_precio: nil, listas_de_precio: nil, series_asociadas: nil, codigo_consultado: nil, lista_referencia: nil
        )
        manager.addItem(product: anotherProduct, unidades: 10, cajas: 2)
        
        return manager
    }
}
#endif