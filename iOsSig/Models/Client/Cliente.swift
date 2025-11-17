import Foundation

struct Cliente: Codable {
  let codcliente: Int
  let nombre: String
  let telefono1: String
  let telefono2: String
  let email: String
  let rut: String?
  let rutnumerico: String
  let jubilado: Int
  let genero: String
  let inactivoprgfidelidad: Int
  let nacimiento: Int
  let suma: Float
  let resta: Float
  let balancePts: Float
  let totalFacturas: Float
  let consumido: Float
}
