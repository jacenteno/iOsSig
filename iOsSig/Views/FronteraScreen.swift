import SwiftUI

struct FronteraScreen: View {
    @StateObject private var viewModel = FronteraViewModel()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Ingrese código", text: $viewModel.codigo)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                viewModel.consultarCodigo()
            }) {
                Text("Consultar")
            }
            .disabled(viewModel.isLoading)

            if viewModel.isLoading {
                ProgressView()
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            ScrollView {
                Text(viewModel.responseText)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Frontera")
    }
}

