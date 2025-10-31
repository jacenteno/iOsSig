import Foundation

// New structs based on API response
struct VentaIngresoItem: Decodable {
    let transacciones: Int
    let monto: Double
}

struct VentaEgresoItem: Decodable {
    let transacciones: Int
    let monto: Double
}

struct TotalDescuentosItem: Decodable {
    let totalTransacciones: Int
    let totalDescuento: Double? // Can be null

    enum CodingKeys: String, CodingKey {
        case totalTransacciones = "total_transacciones"
        case totalDescuento = "total_descuento"
    }
}

struct TotalDescuentos2Item: Decodable {
    let totalTransacciones: Int
    let totalDescuento: Double

    enum CodingKeys: String, CodingKey {
        case totalTransacciones = "total_transacciones"
        case totalDescuento = "total_descuento"
    }
}

struct SalesResponse: Decodable {
    let ventaPorGrupoCaja: [String: SalesSummaryItem]?
    let ventaPorHoraGeneral: [String: SalesByHourItem]?
    let ventaPorGrupoCajaDetalle: [String: AreaDetail]?
    let totalTickets: Int? // Renamed from totalFacturas
    let totalFacturaDelMes: Double?
    let totalClientes: Int?
    let ventaPorHora: [String: [String: SalesByHourDetailItem]]? // Changed to SalesByHourDetailItem
    let ventaPorCaja: [String: CashRegisterSummaryItem]? // Changed to CashRegisterSummaryItem
    let totalesPorCaja2: [String: CashRegisterSummaryItem]? // Changed to CashRegisterSummaryItem
    let fechaClarion: Int?
    let fechaWeb: String?
    let ventaNotaDeCredito: [String: VentaNotaDeCreditoItem]?
    let totalTransaNotaDeCredito: Int?
    let totalCajasNotaDeCredito: Int?
    let totalMontoIngreso: Double?
    let totalMontoEgreso: Double?
    let totalTransacciones: Int?
    let totalMontoFinal: Double?
    let ventaIngreso: [String: VentaIngresoItem]?
    let ventaEgreso: [String: VentaEgresoItem]?
    let totalTransaEgreso: Int?
    let totalTransaIngreso: Int?
    let totalCajasIngreso: Int?
    let totalCajasEgreso: Int?
    let totalDescuentos: TotalDescuentosItem?
    let totalDescuentos2: TotalDescuentos2Item?
    let finalDescuento: Double?
    let totalCajasGrupo: Int?
    let totalTransaccionCajaGrupo: Int?
    let totalMontoCajaGrupo: Double?
    let totalCajas: Int?
    let totalTransaccionCaja: Int?
    let totalMontoCaja: Double?


    enum CodingKeys: String, CodingKey {
        case ventaPorGrupoCaja = "venta_por_grupo_caja"
        case ventaPorHoraGeneral = "venta_por_hora_general"
        case ventaPorGrupoCajaDetalle = "venta_por_grupo_caja_detalle"
        case totalTickets = "total_facturas" // Mapping to the old key
        case totalFacturaDelMes = "total_factura_del_mes"
        case totalClientes = "total_clientes"
        case ventaPorHora = "venta_por_hora"
        case ventaPorCaja = "venta_por_caja"
        case totalesPorCaja2 = "totales_por_caja2"
        case fechaClarion = "fecha_clarion"
        case fechaWeb = "fecha_web"
        case ventaNotaDeCredito = "venta_notadecredito"
        case totalTransaNotaDeCredito = "total_transa_notadecredito"
        case totalCajasNotaDeCredito = "total_cajas_notadecredito"
        case totalMontoIngreso = "total_monto_ingreso"
        case totalMontoEgreso = "total_monto_egreso"
        case totalTransacciones = "total_transacciones"
        case totalMontoFinal = "total_monto_final"
        case ventaIngreso = "venta_ingreso"
        case ventaEgreso = "venta_egreso"
        case totalTransaEgreso = "total_transa_egreso"
        case totalTransaIngreso = "total_transa_ingreso"
        case totalCajasIngreso = "total_cajas_ingreso"
        case totalCajasEgreso = "total_cajas_egreso"
        case totalDescuentos = "total_descuentos"
        case totalDescuentos2 = "total_descuentos_2"
        case finalDescuento = "final_descuento"
        case totalCajasGrupo = "total_cajas_grupo"
        case totalTransaccionCajaGrupo = "total_transaccion_caja_grupo"
        case totalMontoCajaGrupo = "total_monto_caja_grupo"
        case totalCajas = "total_cajas"
        case totalTransaccionCaja = "total_transaccion_caja"
        case totalMontoCaja = "total_monto_caja"
    }

}
