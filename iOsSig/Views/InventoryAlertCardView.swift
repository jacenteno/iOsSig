
import SwiftUI

/// Una vista de tarjeta que muestra una única alerta de inventario.
struct InventoryAlertCardView: View {
    let alert: InventoryAlert
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono y color dinámico según el tipo de alerta
            Image(systemName: alert.type == .outOfStock ? "xmark.octagon.fill" : "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(alert.type == .outOfStock ? .red : .orange)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(alert.product.desproducto ?? "Producto sin nombre")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Cód: \(alert.product.codproducto ?? "N/A") | Ref: \(alert.product.codigobarra ?? "N/A")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)

                Text("Stock actual: \(Int(alert.currentStock)) un.")
                    .font(.subheadline)
                    .foregroundColor(alert.type == .outOfStock ? .red : .secondary)
                
                Text("Ventas mes anterior: \(alert.lastMonthSales) un.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Texto del estado de la alerta
            VStack {
                if alert.type == .outOfStock {
                    Image(systemName: "nosign")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.red)
                    Text("AGOTADO")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "scalemass.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.orange)
                    Text("BAJO STOCK")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    let mockProductAgotado = Product(
        codcompania: 1, codbodega: "B01", coddep: 1, desproducto: "Producto Agotado",
        detalle: "", codigobarra: "12345", codproducto: "PROD-OUT", codproveedor: 1, referencia: "REF-OUT",
        nombre_departamento: "", ultcosto: 10, existencias: 0, ubicacion: "", ofertas: 0,
        ucosto: 0, costofob: 0, indexproductos: 0, costooriginal: 0, preciodeventa: 0,
        fvencimiento: 0, ctacontable: "", bloqueofacturacion: 0, gravadoexecto: "", prcimpuestoventa: 0,
        nombre_lista_precio: "", listas_de_precio: [], series_asociadas: nil, codigo_consultado: "",
        lista_referencia: []
    )
    
    let mockProductBajoStock = Product(
        codcompania: 1, codbodega: "B01", coddep: 1, desproducto: "Producto con Bajo Stock",
        detalle: "", codigobarra: "67890", codproducto: "PROD-LOW", codproveedor: 1, referencia: "REF-LOW",
        nombre_departamento: "", ultcosto: 10, existencias: 40, ubicacion: "", ofertas: 0,
        ucosto: 0, costofob: 0, indexproductos: 0, costooriginal: 0, preciodeventa: 0,
        fvencimiento: 0, ctacontable: "", bloqueofacturacion: 0, gravadoexecto: "", prcimpuestoventa: 0,
        nombre_lista_precio: "", listas_de_precio: [], series_asociadas: nil, codigo_consultado: "",
        lista_referencia: []
    )
    
    let alertAgotado = InventoryAlert(product: mockProductAgotado, currentStock: 0, lastMonthSales: 50, type: .outOfStock)
    let alertBajoStock = InventoryAlert(product: mockProductBajoStock, currentStock: 40, lastMonthSales: 100, type: .lowStock)

    return VStack(spacing: 20) {
        InventoryAlertCardView(alert: alertAgotado)
        InventoryAlertCardView(alert: alertBajoStock)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
