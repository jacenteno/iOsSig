import SwiftUI

struct CambioPrecioView: View {
    let codigo: String
    @StateObject private var viewModel = CambioPrecioViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var productViewModel: ProductViewModel

    var body: some View {
        Form {
            Section(header: Text("Producto")) {
                if let product = viewModel.product {
                    Text(product.desproducto ?? "Sin nombre")
                        .font(.title)
                    Text("Precio Actual: \(String(format: "$%.2f", product.preciodeventa ?? 0.0))")
                        .font(.headline)
                        .foregroundColor(.red)
                } else {
                    Text("Cargando producto...")
                }
            }

            Section(header: Text("Nuevo Precio")) {
                TextField("Nuevo Precio", text: $viewModel.newPriceString)
                    .keyboardType(.decimalPad)
            }

            Section {
                Button(action: {
                    Task {
                        await viewModel.updatePrice(codigo: codigo)
                    }
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Cambiar Precio")
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Cambio de Precio")
        .onAppear {
            Task {
                await viewModel.fetchProduct(codigo: codigo)
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Cambio de Precio"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if viewModel.alertMessage.starts(with: "Precio actualizado") {
                        productViewModel.fetchProducts()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}
