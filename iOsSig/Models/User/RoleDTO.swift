import Foundation

struct RoleDTO: Codable {
  let name: String
  let permissions: [PermissionDTO]
}
