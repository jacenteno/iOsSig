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
        VStack {
            if cartManager.items.isEmpty {
                Spacer()
                Text("No hay productos en el pedido.")
                    .font(.title)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List(selection: $selection) {
                    ForEach(cartManager.items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.product.desproducto ?? "N/A")
                                    .font(.headline)
                                Text("Unidades: \(item.unidades), Cajas: \(item.cajas)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .tag(item.id)
                    }
                }

                // Totals Section
                let totalUnidades = cartManager.items.reduce(0) { $0 + $1.unidades }
                let totalCajas = cartManager.items.reduce(0) { $0 + $1.cajas }

                VStack(spacing: 8) {
                    HStack {
                        Text("Total Unidades:")
                            .font(.headline)
                        Spacer()
                        Text("\(totalUnidades)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("Total Cajas:")
                            .font(.headline)
                        Spacer()
                        Text("\(totalCajas)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                .padding()

                if isEditing {
                    HStack {
                        Button(action: selectAll) {
                            Text("Seleccionar Todo")
                        }
                        Spacer()
                        Button(action: deleteSelection) {
                            Text("Borrar Selección")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                }

                Button(action: {
                    Task {
                        await viewModel.createOrder(cartManager: cartManager)
                    }
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Enviar Pedido")
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .disabled(viewModel.isLoading || isEditing)
            }
        }
        .navigationTitle("Hacer Pedido")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Pedido a Bodega"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func selectAll() {
        selection = Set(cartManager.items.map { $0.id })
    }

    private func deleteSelection() {
        selection.forEach { cartManager.removeItem(productID: $0) }
        selection.removeAll()
    }
}
