import SwiftUI

struct FronteraCardView: View {
  let resultado: Resultado
  @State private var showDetails = true
  @State private var selectedTab = 0
  @State private var showTabContent = true
  @EnvironmentObject var settings: SettingsManager

  var body: some View {
    VStack(spacing: 0) {
      productHeaderView
        .padding()

      detailsSection
    }
    .background(Color(.systemBackground))
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    .onAppear {
      // Auto-expand if it's a single result
      withAnimation(.spring()) {
        showDetails = true
      }
    }
  }

  private var productHeaderView: some View {
    HStack(alignment: .top, spacing: 16) {
      // Product Image (if available)
      //
      // if let imageUrlString = resultado.imagenproducto, let url = URL(string: imageUrlString) {
      //     AsyncImage(url: url) {
      //         image in image.resizable()
      //     } placeholder: {
      //         ProgressView()
      //    }
      //   .frame(width: 60, height: 60)
      //   .cornerRadius(8)
      //} else {
      //    Image(systemName: "shippingbox.fill")
      //        .font(.title)
      //        .frame(width: 60, height: 60)
      //        .background(Color.accentColor.opacity(0.1))
      //        .foregroundColor(.accentColor)
      //        .cornerRadius(8)
      // }

      // Product Details
      VStack(alignment: .leading, spacing: 4) {
        Text(resultado.nombreproducto ?? "Sin nombre")
          .font(.headline)
          .lineLimit(2)

        if let referencia = resultado.referencia, !referencia.isEmpty {
          Text(referencia)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }

        Text(resultado.codigoproducto ?? "N/A")
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
      }

      Spacer()

      // Price
      if let price = resultado.precioventa {
        VStack(alignment: .trailing) {
          Text(String(format: "$%.2f", price))
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.red)
          if let priceName = resultado.nombreprecio {
            Text(priceName)
              .font(.caption)
              .padding(4)
              .background(Color.red.opacity(0.1))
              .cornerRadius(4)
          }
        }
      }
    }
  }

  @ViewBuilder
  private var detailsSection: some View {
    Divider().padding(.horizontal)

    Button(action: {
      withAnimation(.spring(response: 0.3)) {
        showDetails.toggle()
      }
    }) {
      HStack {
        Text(showDetails ? "Ocultar información" : "Ver información completa")
          .font(.subheadline)
          .fontWeight(.medium)
        Spacer()
        Image(systemName: showDetails ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
      }
      .foregroundColor(.accentColor)
      .padding()
    }

    if showDetails {
      VStack(spacing: 16) {
        actionGridView

        if showTabContent {
          Divider().padding(.horizontal)
          tabContentView
            .transition(.opacity)
        }
      }
      .padding(.horizontal)
      .padding(.bottom)
    }
  }

  private var actionGridView: some View {
    HStack(spacing: 12) {
      ActionGridButton(
        icon: "info.circle.fill",
        title: "Detalles",
        isSelected: selectedTab == 0,
        color: .accentColor
      ) {
        withAnimation {
          selectedTab = 0
          showTabContent.toggle()
        }
      }

      if resultado.ventas != nil && settings.hasPermission("Ver_Ventas_en_Consulta_Producto") {
        ActionGridButton(
          icon: "chart.bar.fill",
          title: "Ventas",
          isSelected: selectedTab == 1,
          color: .blue
        ) {
          withAnimation {
            selectedTab = 1
            showTabContent = true
          }
        }
      }

      if resultado.compras != nil && settings.hasPermission("Ver_Compras_en_Consulta_Producto") {
        ActionGridButton(
          icon: "cart.fill",
          title: "Compras",
          isSelected: selectedTab == 2,
          color: .green
        ) {
          withAnimation {
            selectedTab = 2
            showTabContent = true
          }
        }
      }
    }
  }

  @ViewBuilder
  private var tabContentView: some View {
    switch selectedTab {
    case 0:
      FronteraDetailsView(resultado: resultado)
        .environmentObject(settings)
    case 1:
      if let ventas = resultado.ventas {
        NewSalesDetailView(sales: ventas)
      } else {
        EmptyView()
      }
    case 2:
      if resultado.compras != nil {
        PurchasesDetailView(citymallProd: resultado)
      } else {
        EmptyView()
      }
    default:
      EmptyView()
    }
  }
}

struct FronteraDetailsView: View {
  let resultado: Resultado
  @EnvironmentObject var settings: SettingsManager

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      InfoRow(label: "Código Producto", value: resultado.codigoproducto ?? "N/A")
      InfoRow(label: "Referencia", value: resultado.referencia ?? "N/A")

      // if settings.userRole.hasPermission("VIEW_INVENTARIO") {
      if settings.hasPermission("VIEW_INVENTARIO") {
        let existencias = resultado.existencias ?? 0
        let textColor: Color = existencias <= 0 ? .red : .green
        let textFont: Font = .title3  // Large font

        InfoRow(
          label: "Existencias", value: String(existencias), valueTextColor: textColor,
          valueTextFont: textFont)
      }

      // if settings.userRole.hasPermission("VIEW_COSTO") {
      if settings.hasPermission("VIEW_COSTO") {
        InfoRow(label: "Último Costo", value: String(format: "$%.6f", resultado.ultimocosto ?? 0.0))
      }

      InfoRow(label: "Tasa IVA", value: String(resultado.tasaiva ?? 0))

      Divider()

      InfoRow(label: "Cód. Precio", value: resultado.codigoprecio ?? "N/A")
      InfoRow(label: "Nombre Precio", value: resultado.nombreprecio ?? "N/A")
      InfoRow(label: "Moneda", value: resultado.nombremoneda ?? "N/A")
      InfoRow(label: "Símbolo", value: resultado.simbolomoneda ?? "N/A")

      if let sucursales = resultado.preciossucursales, !sucursales.isEmpty {
        Divider()
        Text("Precios en Sucursales").font(.headline)
        ForEach(sucursales, id: \.codprecio) { sucursal in
          HStack {
            Text(sucursal.nombreprecio)
            Spacer()
            Text(String(format: "$%.2f", sucursal.precioventa))
              .fontWeight(.semibold)
          }
        }
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}
