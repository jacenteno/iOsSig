import Foundation

struct CompraHistorial: Codable {
  let numdoc: String
  let tipo: String
  let costou: Double
  let costop: Double
  let cEnt: Int?
  let cSal: Int?
  let fecmov: String
  let prov: String

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    numdoc = try container.decode(String.self, forKey: .numdoc)
    tipo = try container.decode(String.self, forKey: .tipo)
    costou = try container.decode(Double.self, forKey: .costou)
    costop = try container.decode(Double.self, forKey: .costop)
    fecmov = try container.decode(String.self, forKey: .fecmov)
    prov = try container.decode(String.self, forKey: .prov)

    do {
      cEnt = try container.decode(Int.self, forKey: .cEnt)
    } catch {
      print("Failed to decode cEnt as Int: \(error)")
      do {
        let cEntString = try container.decode(String.self, forKey: .cEnt)
        cEnt = Int(cEntString)
      } catch {
        print("Failed to decode cEnt as String: \(error)")
        cEnt = nil
      }
    }

    do {
      cSal = try container.decode(Int.self, forKey: .cSal)
    } catch {
      print("Failed to decode cSal as Int: \(error)")
      do {
        let cSalString = try container.decode(String.self, forKey: .cSal)
        cSal = Int(cSalString)
      } catch {
        print("Failed to decode cSal as String: \(error)")
        cSal = nil
      }
    }
    print(
      "DEBUG CompraHistorial - Custom Init - numdoc: \(numdoc), cEnt raw (after conversion): \(cEnt ?? -999), cSal raw (after conversion): \(cSal ?? -999)"
    )
  }
}
