import SwiftUI

struct FronteraScreen: View, CameraScannerViewDelegate {
    @StateObject private var viewModel = FronteraViewModel()
    @State private var isShowingScanner = false

    var body: some View {
        VStack(spacing: 0) {
            searchHeaderView
                .padding()

            contentView
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Frontera")
        .sheet(isPresented: $isShowingScanner) {
            CameraScannerView(delegate: self)
        }
    }

    // MARK: - Subviews

    private var searchHeaderView: some View {
        HStack(spacing: 12) {
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Buscar por código...", text: $viewModel.searchQuery, onCommit: {
                    viewModel.consultarCodigo()
                })
                .textFieldStyle(.plain)

                if !viewModel.searchQuery.isEmpty {
                    Button(action: { viewModel.searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray5))
            .cornerRadius(12)

            // Scanner Button
            Button(action: { isShowingScanner = true }) {
                Image(systemName: "barcode.viewfinder")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            
            // Clear Button
            Button(action: { viewModel.clear() }) {
                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundColor(.red)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView("Consultando...")
            Spacer()
        } else if let errorMessage = viewModel.errorMessage {
            ErrorState(message: errorMessage, onRetry: {
                viewModel.consultarCodigo()
            })
        } else if let resultado = viewModel.resultado {
            ScrollView {
                FronteraCardView(resultado: resultado)
                    .padding()
            }
        } else {
            EmptyStateView(systemImage: "shippingbox.fill", message: "Consulte un código de producto para ver su información de frontera.")
        }
    }
    
    // MARK: - CameraScannerViewDelegate
    
    func didScanBarcode(code: String) {
        viewModel.searchQuery = code
        isShowingScanner = false
        // La consulta se dispara automáticamente gracias al binding con debounce en el ViewModel
    }
}

// MARK: - Preview
struct FronteraScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FronteraScreen()
        }
    }
}

