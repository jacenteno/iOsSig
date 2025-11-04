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
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Basic Information Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Información Básica")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 16) {
                                CustomTextField(placeholder: "Código de Producto", text: $viewModel.codproducto, isDisabled: true)
                                CustomTextField(placeholder: "Descripción", text: $viewModel.desproducto)
                                CustomTextField(placeholder: "Referencia", text: $viewModel.codigobarra)
                             //   CustomTextField(placeholder: "Código de Barra", text: $viewModel.referencia)
                            }
                        }
                        
                        // Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Detalles")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if viewModel.isFetchingDepartments {
                                HStack {
                                    Text("Departamento")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    ProgressView()
                                }
                                .modifier(CustomSectionStyle())
                            } else {
                                CustomIntPicker(title: "Departamento", selection: $viewModel.departamentoSeleccionado) {
                                    ForEach(viewModel.departamentos, id: \.coddepartamento) { depto in
                                        Text(depto.nomdepto.trimmingCharacters(in: .whitespacesAndNewlines)).tag(depto.coddepartamento as Int?)
                                    }
                                }
                            }
                            
                            CustomPicker(title: "Impuesto", selection: $viewModel.selectedTaxOption) {
                                ForEach(viewModel.taxOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                        }
                        
                        // Pricing Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Precios")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            CustomTextField(placeholder: "Precio de Venta", text: $viewModel.preciodeventa, keyboardType: .decimalPad)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                
                // Save Button Area
                VStack {
                    Spacer()
                    if settings.userRole.hasPermission("CREAR_PRODUCTO") {
                        Button(action: {
                            viewModel.crearProducto()
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Crear Producto")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        .disabled(viewModel.isLoading)
                        .padding()
                    }
                }
            }
            .navigationTitle("Crear Nuevo Producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                print("CreaProductoView: onAppear at \(Date())")
                print("CreaProductoView: onAppear - calling fetchDepartamentos()")
                viewModel.codproducto = codigoDeReferencia ?? ""
                viewModel.fetchDepartamentos()
            }
            .alert(isPresented: .constant(viewModel.errorMessage != nil || viewModel.successMessage != nil)) {
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
