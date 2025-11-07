import Foundation
import Combine

@MainActor
class RoleManagementViewModel: ObservableObject {
    @Published var roles: [String] = []
    private var settings: SettingsManager

    init(settings: SettingsManager = .shared) {
        self.settings = settings
        loadRoles()
    }

    func loadRoles() {
        // Los roles se cargan de las claves del diccionario de permisos
        self.roles = settings.rolePermissions.keys.sorted()
    }
}
