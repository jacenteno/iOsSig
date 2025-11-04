import Foundation

struct Departamento: Codable, Identifiable {
    let coddepartamento: Int
    let nomdepto: String
    
    var id: Int { coddepartamento }
}
