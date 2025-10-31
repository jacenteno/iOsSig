import SwiftUI

struct EtiquetaScreen: View {
    let product: Product
    @StateObject private var viewModel = EtiquetaViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Producto")) {
                Text(product.desproducto ?? "Sin nombre")
                    .font(.title)
            }

            Section(header: Text("Cantidad de Etiquetas")) {
                TextField("Cantidad", text: $viewModel.cantidad)
                    .keyboardType(.numberPad)
            }

            Section {
                Button(action: {
                    viewModel.printLabels(product: product)
                }) {
                    HStack {
                        Spacer()
                        Text("Imprimir")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Imprimir Etiquetas")
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Impresión de Etiquetas"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if viewModel.alertMessage.starts(with: "Se han enviado") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}