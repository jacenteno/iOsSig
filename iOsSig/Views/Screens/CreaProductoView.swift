import SwiftUI

struct CreaProductoView: View {
  @Environment(\.presentationMode) var presentationMode
  @StateObject private var viewModel = CreaProductoViewModel()
  @EnvironmentObject var settings: SettingsManager

  var codigoDeReferencia: String?

  init(codigoDeReferencia: String?) {
    self.codigoDeReferencia = codigoDeReferencia
    _viewModel = StateObject(wrappedValue: CreaProductoViewModel())
  }

  var body: some View {
    let accentColor = Color(hex: settings.accentColor) ?? .accentColor

    NavigationView {
      ZStack {
        Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)

        ScrollView {
          VStack(spacing: 24) {
            GroupBox {
              VStack(alignment: .leading, spacing: 12) {
                Label("Información Básica", systemImage: "info.circle")
                  .font(.headline)
                  .foregroundColor(.primary)

                CustomTextField(
                  placeholder: "Código de Producto", text: $viewModel.codproducto, isDisabled: true)
                CustomTextField(placeholder: "Descripción", text: $viewModel.desproducto)
                CustomTextField(placeholder: "Referencia", text: $viewModel.codigobarra)
              }
            }

            GroupBox {
              VStack(alignment: .leading, spacing: 12) {
                Label("Detalles", systemImage: "list.bullet.rectangle")
                  .font(.headline)
                  .foregroundColor(.primary)

                if viewModel.isFetchingDepartments {
                  HStack {
                    Text("Cargando departamentos...")
                      .font(.subheadline)
                      .foregroundColor(.secondary)
                    Spacer()
                    ProgressView()
                  }
                } else {
                  CustomIntPicker(
                    title: "Departamento", selection: $viewModel.departamentoSeleccionado
                  ) {
                    ForEach(viewModel.departamentos, id: \.coddepartamento) { depto in
                      Text(depto.nomdepto.trimmingCharacters(in: .whitespacesAndNewlines)).tag(
                        depto.coddepartamento as Int?)
                    }
                  }
                  .accentColor(accentColor)
                }

                CustomPicker(title: "Impuesto", selection: $viewModel.selectedTaxOption) {
                  ForEach(viewModel.taxOptions, id: \.self) { option in
                    Text(option).tag(option)
                  }
                }
                .accentColor(accentColor)
              }
            }

            GroupBox {
              VStack(alignment: .leading, spacing: 12) {
                Label("Precios", systemImage: "dollarsign.circle")
                  .font(.headline)
                  .foregroundColor(.primary)

                CustomTextField(
                  placeholder: "Precio de Venta", text: $viewModel.preciodeventa,
                  keyboardType: .decimalPad)
              }
            }

            Spacer(minLength: 100)
          }
          .padding()
        }

        // Floating Action Button (FAB)
        if settings.hasPermission("CREAR_PRODUCTO") {
          VStack {
            Spacer()
            HStack {
              Spacer()
              Button(action: {
                viewModel.crearProducto()
              }) {
                if viewModel.isLoading {
                  ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(width: 56, height: 56)
                } else {
                  Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                }
              }
              .background(accentColor)
              .clipShape(Circle())
              .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
              .padding(20)
              .disabled(viewModel.isLoading)
            }
          }
        }
      }
      .navigationTitle("Nuevo Producto")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancelar") {
            presentationMode.wrappedValue.dismiss()
          }
          .foregroundColor(accentColor)
        }
      }
      .onAppear {
        print("CreaProductoView: onAppear at \(Date())")
        print("CreaProductoView: onAppear - calling fetchDepartamentos()")
        viewModel.codproducto = codigoDeReferencia ?? ""
        viewModel.fetchDepartamentos()
      }
      .alert(
        isPresented: .constant(viewModel.errorMessage != nil || viewModel.successMessage != nil)
      ) {
        Alert(
          title: Text(viewModel.successMessage != nil ? "Éxito" : "Error"),
          message: Text(viewModel.successMessage ?? viewModel.errorMessage ?? ""),
          dismissButton: .default(Text("OK")) {
            if viewModel.successMessage != nil {
              presentationMode.wrappedValue.dismiss()
            }
            viewModel.errorMessage = nil
            viewModel.successMessage = nil
          }
        )
      }
    }
  }
}

struct CreaProductoView_Previews: PreviewProvider {
  static var previews: some View {
    CreaProductoView(codigoDeReferencia: "123456789")
      .environmentObject(SettingsManager.shared)
  }
}
