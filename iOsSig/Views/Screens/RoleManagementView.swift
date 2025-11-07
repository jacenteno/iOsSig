import SwiftUI

struct RoleManagementView: View {
    @StateObject private var viewModel = RoleManagementViewModel()

    var body: some View {
        List {
            ForEach(viewModel.roles, id: \.self) { roleName in
                NavigationLink(destination: RoleEditView(roleName: roleName)) {
                    Text(roleName)
                        .font(.headline)
                }
            }
        }
        .navigationTitle("Gestionar Roles")
        .onAppear {
            viewModel.loadRoles()
        }
    }
}

struct RoleManagementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoleManagementView()
                .environmentObject(SettingsManager.shared)
        }
    }
}
