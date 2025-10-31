import SwiftUI

struct AddProductToOrderView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.presentationMode) var presentationMode

    @State private var unidades: String = ""
    @State private var cajas: String = "1"
    @FocusState private var isCajasFieldFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Producto")) {
                    Text(product.desproducto ?? "Sin nombre")
                        .font(.title)
                }

                Section(header: Text("Cantidades")) {
                    TextField("Unidades", text: $unidades)
                        .keyboardType(.numberPad)
                    TextField("Cajas", text: $cajas)
                        .keyboardType(.numberPad)
                        .focused($isCajasFieldFocused)
                }

                Section {
                    Button(action: {
                        let unidadesInt = Int(unidades) ?? 0
                        let cajasInt = Int(cajas) ?? 0
                        if unidadesInt > 0 || cajasInt > 0 {
                            cartManager.addItem(product: product, unidades: unidadesInt, cajas: cajasInt)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Agregar al Pedido")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Agregar al Pedido")
            .navigationBarItems(trailing: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                // Add a small delay to ensure the view is ready for focus
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isCajasFieldFocused = true
                }
            }
        }
    }
}