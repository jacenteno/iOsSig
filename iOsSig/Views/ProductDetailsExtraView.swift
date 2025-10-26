import SwiftUI

struct SalesContent2: View {
    let venta: Venta?

    var body: some View {
        if let venta = venta {
            VStack(alignment: .leading) {
                Text("Total Vendido: \(venta.totalVendido, specifier: "%.2f")")
                Text("Monto Total: \(venta.totalMonto, specifier: "%.2f")")
                List(venta.ventasMensuales) { ventaMensual in
                    HStack {
                        Text("\(ventaMensual.mes)/\(ventaMensual.anio)")
                        Spacer()
                        Text("Cantidad: \(ventaMensual.totalUnidades, specifier: "%.2f")")
                        Spacer()
                        Text("Monto: \(ventaMensual.totalMontos, specifier: "%.2f")")
                    }
                }
            }
        } else {
            Text("No hay datos de ventas.")
        }
    }
}

struct PurchasesContent2: View {
    let citymallProd: Resultado?

    var body: some View {
        if let citymallProd = citymallProd {
            switch citymallProd.compras {
            case .listaCompras(let compras):
                List(compras, id: \.numdoc) { compra in
                    VStack(alignment: .leading) {
                        Text("Documento: \(compra.numdoc)")
                        Text("Fecha: \(compra.fecmov)")
                        Text("Proveedor: \(compra.prov)")
                        Text("Costo: \(compra.costou, specifier: "%.2f")")
                    }
                }
            case .mensaje(let mensaje):
                Text(mensaje)
            }
        } else {
            Text("No hay datos de compras.")
        }
    }
}

struct MonthlySaleCard2: View {
    var body: some View {
        Text("Monthly Sale Card")
    }
}

struct CitymallCompras: View {
    var body: some View {
        Text("Citymall Compras")
    }
}