import SwiftUI

struct SyncProductsView: View {
    @StateObject private var viewModel = SyncProductsViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color.accentColor.opacity(0.03)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

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
            VStack(alignment: .center, spacing: 16) {
                Image(systemName: "arrow.triangle.2.circlepath.icloud.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(LinearGradient(colors: [.accentColor, .accentColor.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                
                Text("Productos en la Base de Datos Local")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.localProductsCount)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                if viewModel.isSyncing {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Sincronizando: \(viewModel.syncMessage)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(viewModel.syncProgress * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        ProgressView(value: viewModel.syncProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                    }
                    .padding(.horizontal)
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
        Section(header: Text("Seleccionar Departamentos"), footer: Text("Selecciona los departamentos que deseas sincronizar.")) {
            HStack {
                Button("Seleccionar Todos") {
                    viewModel.selectAllDepartments()
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Deseleccionar Todos") {
                    viewModel.deselectAllDepartments()
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 4)

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
                        Text("Sincronizar \(viewModel.selectedDepartmentIDs.count) Departamentos")
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.selectedDepartmentIDs.isEmpty)
            }
        }
        .listRowBackground(Color.clear)
    }
}


#Preview {
    SyncProductsView()
}
