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
        .navigationTitle("Editar Rol")
        .toolbar {
            // El botón de guardar se ha eliminado porque los cambios son automáticos.
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
