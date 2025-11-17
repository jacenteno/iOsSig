import Foundation

// Equivalente al enum UserRole en Kotlin
enum UserRole: String, CaseIterable, Codable {
  case viewer = "VIEWER"
  case editor = "EDITOR"
  case admin = "ADMIN"
  case fullAccess = "FULL_ACCESS"
  case david = "DAVID"
  case frontera = "FRONTERA"
  case offline = "OFFLINE"
  case pedidos = "PEDIDOS"

  // Puedes añadir funciones para comprobar permisos como en tu app de Android
  func hasPermission(for action: String) -> Bool {
    switch self {
    case .viewer:
      return action == "VIEW_HOME" || action.hasPrefix("VIEW_")
    case .editor:
      return action.hasPrefix("VIEW_") || action.hasPrefix("EDIT_")
    case .admin:
      return true  // O una lógica más granular
    case .fullAccess:
      return true
    case .david:
      return action == "VIEW_DAVID"
    // Añade la lógica para los otros roles según tus necesidades
    default:
      return false
    }
  }
}

struct User {
  let username: String
  let role: UserRole
}
