import Foundation

struct SalesResponse: Decodable {
    let ventaPorGrupoCaja: [String: SalesSummaryItem]
    let ventaPorHoraGeneral: [String: SalesByHourItem]
    let ventaPorGrupoCajaDetalle: [String: AreaDetail]
    let totalFacturas: Int
    let totalMontoIngreso: Double
    let totalMontoEgreso: Double
    let totalTransacciones: Int
    let totalMontoFinal: Double
    let finalDescuento: Double
    let totalMontoNotaCredito: Double

    enum CodingKeys: String, CodingKey {
        case ventaPorGrupoCaja = "venta_por_grupo_caja"
        case ventaPorHoraGeneral = "venta_por_hora_general"
        case ventaPorGrupoCajaDetalle = "venta_por_grupo_caja_detlle" // JSON key has a typo
        case totalFacturas = "total_facturas"
        case totalMontoIngreso = "total_monto_ingreso"
        case totalMontoEgreso = "total_monto_egreso"
        case totalTransacciones = "total_transacciones"
        case totalMontoFinal = "total_monto_final"
        case finalDescuento = "final_descuento"
        case totalMontoNotaCredito = "total_monto_notadecredito"
    }
}
