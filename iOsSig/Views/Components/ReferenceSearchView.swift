import Combine
import SwiftUI

struct ReferenceSearchView: View {
  @Binding var isPresented: Bool
  var onSearch: (String) -> Void  // This will be called when "Enviar" is tapped with a selected product

  @StateObject private var viewModel = ReferenceSearchViewModel()
  @EnvironmentObject var settings: SettingsManager

  var body: some View {
    let accentColor = Color(hex: settings.accentColor) ?? .accentColor

    NavigationView {
      VStack(spacing: 0) {
        Text("Buscar por Referencia")
          .font(.largeTitle)
          .fontWeight(.bold)
          .padding(.bottom, 5)

        Text("Ingrese el código de referencia o código de barras del producto que desea buscar.")
          .font(.subheadline)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
          .padding(.bottom, 20)

        HStack {
          Image(systemName: "text.magnifyingglass")
            .foregroundColor(.secondary)
          TextField("Código de referencia", text: $viewModel.referenceQuery)
            .textFieldStyle(.plain)
            .onChange(of: viewModel.referenceQuery) { newValue in
              viewModel.performSearch(query: newValue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom, 10)

        if viewModel.isLoading {
          ProgressView()
            .padding()
        } else if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
            .foregroundColor(.red)
            .padding()
        } else if viewModel.searchResults.isEmpty && !viewModel.referenceQuery.isEmpty {
          Text("No se encontraron referencias.")
            .foregroundColor(.secondary)
            .padding()
                        } else if !viewModel.searchResults.isEmpty {
                            List {
                                ForEach(viewModel.searchResults) { producto in
                                    Button(action: {
                                        onSearch(producto.codigobarra)
                                        isPresented = false
                                    }) {
                                        VStack(alignment: .leading) {
                                            Text(producto.desproducto)
                                                .font(.headline)
                                            Text(producto.codigobarra)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .listStyle(.plain)
                        }
        Spacer()

        HStack {
          Button(action: {
            isPresented = false
          }) {
            Text("Volver")
              .fontWeight(.semibold)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.gray.opacity(0.2))
              .foregroundColor(.primary)
              .cornerRadius(12)
          }

          Button(action: {
            // This button will only be active if a selection is made from the list
            // For now, it will just send the current query if no selection is made
            onSearch(viewModel.referenceQuery)
            isPresented = false
          }) {
            Text("Enviar")
              .fontWeight(.semibold)
              .frame(maxWidth: .infinity)
              .padding()
              .background(accentColor)
              .foregroundColor(.white)
              .cornerRadius(12)
          }
          .disabled(viewModel.referenceQuery.isEmpty)  // Disable if no text
        }
        .padding(.horizontal)
        .padding(.bottom)
      }
      .padding(.top, 20)
      .background(
        LinearGradient(
          colors: [Color(.systemBackground), Color(.systemGray5)],
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()
      )
      .navigationBarHidden(true)  // Hide default navigation bar
    }
    .accentColor(accentColor)
  }
}
