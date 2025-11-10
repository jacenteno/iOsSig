import SwiftUI

struct RoleEditView: View {
    @StateObject private var viewModel: RoleEditViewModel
    @Environment(\.presentationMode) var presentationMode

    init(roleName: String) {
        _viewModel = StateObject(wrappedValue: RoleEditViewModel(roleName: roleName))
    }

    var body: some View {
        Form {
            Section(header: Text("Permisos para \(viewModel.roleName)")) {
                ForEach(viewModel.allPossiblePermissions, id: \.self) { permission in
                    Toggle(isOn: Binding(
                        get: { viewModel.hasPermission(permission) },
                        set: { _ in viewModel.togglePermission(permission) }
                    )) {
                        Text(permission)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
        }
        .padding(.bottom, 80) // Padding to avoid FAB obstruction
        .navigationTitle("Editar Rol")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    viewModel.saveChanges()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct RoleEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoleEditView(roleName: "ROL_1")
                .environmentObject(SettingsManager.shared)
        }
    }
}
