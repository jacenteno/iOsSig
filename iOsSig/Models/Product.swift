
import Foundation

// Equivalente a la data class Product.kt
// Conforme a Codable para decodificar JSON y a Identifiable para las listas de SwiftUI.
struct Product: Codable, Identifiable {
    let id = UUID() // Requerido por Identifiable
    let codcompania: Int
    let codbodega: String
    let coddep: Int
    let desproducto: String
    let detalle: String
    let codigobarra: String
    let codproducto: String
    let codproveedor: Int
    let referencia: String
    let nombre_departamento: String
    let ultcosto: Double
    let existencias: Double
    let ubicacion: String
    let ofertas: Int
    let ucosto: Double
    let costofob: Double
    let indexproductos: Int
    let costooriginal: Double?
    let preciodeventa: Double
    let fvencimiento: Int
    let ctacontable: String
    let bloqueofacturacion: Int
    let gravadoexecto: String
    let prcimpuestoventa: Double
    let nombre_lista_precio: String?
    let listas_de_precio: [PriceList]
    let series_asociadas: SeriesAsociadas?
    let codigo_consultado: String
    let lista_referencia: [ReferenciaProducto]

    // Mapeo de claves JSON a propiedades de Swift (si son diferentes)
    enum CodingKeys: String, CodingKey {
        case codcompania, codbodega, coddep, desproducto, detalle, codigobarra, codproducto, codproveedor, referencia, nombre_departamento, ultcosto, existencias, ubicacion, ofertas, ucosto, costofob, indexproductos, costooriginal, preciodeventa, fvencimiento, ctacontable, bloqueofacturacion, gravadoexecto, prcimpuestoventa, nombre_lista_precio, listas_de_precio, series_asociadas, codigo_consultado, lista_referencia
    }
}

struct PriceList: Codable {
    let idlistadeprecio: Int
    let codgrprecio: Int
    let codbodega: String
    let preciodeventa: Double
    // ... otros campos si son necesarios
}

struct SeriesAsociadas: Codable {
    let total_series: Int
    let series: [String]
    let tiene_multiples_series: Bool
}

struct ReferenciaProducto: Codable {
    let codproducto: String
    let desproducto: String
    let codigobarra: String
}

// Mock para previews de SwiftUI
extension Product {
    static var sample: Product {
        Product(
            codcompania: 1,
            codbodega: "B01",
            coddep: 10,
            desproducto: "Producto de Ejemplo",
            detalle: "Detalle del producto de ejemplo",
            codigobarra: "1234567890123",
            codproducto: "PROD-001",
            codproveedor: 123,
            referencia: "REF-001",
            nombre_departamento: "Electrónica",
            ultcosto: 99.99,
            existencias: 150.0,
            ubicacion: "Pasillo 5, Estante A",
            ofertas: 0,
            ucosto: 95.50,
            costofob: 90.0,
            indexproductos: 1,
            costooriginal: 105.0,
            preciodeventa: 149.99,
            fvencimiento: 20251231,
            ctacontable: "112233",
            bloqueofacturacion: 0,
            gravadoexecto: "G",
            prcimpuestoventa: 0.15,
            nombre_lista_precio: "General",
            listas_de_precio: [],
            series_asociadas: nil,
            codigo_consultado: "1234567890123",
            lista_referencia: []
        )
    }
}
