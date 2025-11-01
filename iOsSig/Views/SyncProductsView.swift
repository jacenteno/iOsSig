import SwiftUI

struct SyncProductsView: View {
    @StateObject private var viewModel = SyncProductsViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.departments.isEmpty {
                ProgressView("Cargando departamentos...")
            } else {
                List {
                    HeaderSection(viewModel: viewModel)
                    DepartmentSelectionSection(viewModel: viewModel)
                    ActionSection(viewModel: viewModel)
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("Sincronización")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Hecho") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear(perform: viewModel.onAppear)
        .alert(isPresented: .constant(viewModel.errorMessage != nil), content: {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Ocurrió un error desconocido."),
                dismissButton: .default(Text("OK")) { 
                    viewModel.errorMessage = nil
                }
            )
        })
    }
}

private struct HeaderSection: View {
    @ObservedObject var viewModel: SyncProductsViewModel
    
    var body: some View {
        Section {
            VStack(alignment: .center, spacing: 12) {
                Text("Productos en la Base de Datos Local")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.localProductsCount)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                if viewModel.isSyncing {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total a Sincronizar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.totalItemsToSync)")
                                .font(.headline)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Nuevos Registros")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.newItemsSynced)")
                                .font(.headline)
                        }
                    }
                    .padding(.horizontal)

                    ProgressView(value: viewModel.syncProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)

                    Text(viewModel.syncMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                } else if viewModel.isLoading {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
    }
}

private struct DepartmentSelectionSection: View {
    @ObservedObject var viewModel: SyncProductsViewModel
    
    var body: some View {
        Section(header: Text("Seleccionar Departamentos")) {
            ForEach(viewModel.departments) { department in
                HStack {
                    Text(department.nomdepto)
                    Spacer()
                    if viewModel.selectedDepartmentIDs.contains(department.coddepartamento) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.selectedDepartmentIDs.contains(department.coddepartamento) {
                        viewModel.selectedDepartmentIDs.remove(department.coddepartamento)
                    } else {
                        viewModel.selectedDepartmentIDs.insert(department.coddepartamento)
                    }
                }
            }
        }
    }
}

private struct ActionSection: View {
    @ObservedObject var viewModel: SyncProductsViewModel
    
    var body: some View {
        Section {
            if viewModel.isSyncing {
                Button(action: { 
                    viewModel.cancelSync()
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Cancelar Sincronización")
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                Button(action: { 
                    viewModel.syncProducts()
                }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sincronizar Productos Seleccionados")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(viewModel.selectedDepartmentIDs.isEmpty)
            }
        }
    }
}


#Preview {
    SyncProductsView()
}
