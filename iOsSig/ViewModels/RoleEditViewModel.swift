import Foundation
import Combine

@MainActor
class RoleEditViewModel: ObservableObject {
    @Published var roleName: String
    @Published var permissions: Set<String>
    @Published var allPossiblePermissions: [String]

    private var settings: SettingsManager

    init(roleName: String, settings: SettingsManager = .shared) {
        self.roleName = roleName
        self.settings = settings
        
        // Cargar los permisos actuales para este rol
        self.permissions = settings.rolePermissions[roleName] ?? []
        
        // Cargar todos los permisos posibles para mostrarlos en la lista
        self.allPossiblePermissions = SettingsManager.allPermissions
    }

    /// Comprueba si el rol tiene un permiso específico.
    func hasPermission(_ permission: String) -> Bool {
        return permissions.contains(permission)
    }

    /// Activa o desactiva un permiso para el rol.
    func togglePermission(_ permission: String) {
        if permissions.contains(permission) {
            permissions.remove(permission)
        } else {
            permissions.insert(permission)
        }
    }

    /// Guarda los cambios en el SettingsManager.
    func saveChanges() {
        settings.rolePermissions[roleName] = permissions
        // El `didSet` en `rolePermissions` de SettingsManager se encargará de guardarlo en UserDefaults.
        print("Permisos para el rol '\(roleName)' actualizados.")
    }
}
