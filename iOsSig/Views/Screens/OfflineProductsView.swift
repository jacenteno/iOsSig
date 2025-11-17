import SwiftUI

struct OfflineProductsView: View {
  @StateObject private var viewModel = OfflineProductsViewModel()
  @EnvironmentObject var settings: SettingsManager
  @Binding var isPresented: Bool

  var body: some View {
    VStack(spacing: 0) {
      // Header con gradiente
      VStack(spacing: 12) {
        HStack {
          Image(systemName: "arrow.down.circle.fill")
            .font(.title2)
            .foregroundColor(.accentColor)
          Text("Consulta Offline")
            .font(.title2)
            .fontWeight(.bold)
          Spacer()
          Text("Registros: \(viewModel.products.count)")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
              Capsule()
                .fill(Color.accentColor.gradient)
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)

        SearchBarView(text: $viewModel.searchText, prompt: "Buscar por código, descripción...")
          .padding(.horizontal)
      }
      .padding(.bottom, 12)
      .background(
        LinearGradient(
          colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
          startPoint: .top,
          endPoint: .bottom
        )
      )

      if viewModel.isLoading && viewModel.products.isEmpty {
        Spacer()
        VStack(spacing: 16) {
          ProgressView()
            .scaleEffect(1.2)
          Text("Cargando productos...")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        Spacer()
      } else if viewModel.products.isEmpty {
        Spacer()
        if viewModel.searchText.isEmpty {
          EmptyStateView(
            systemImage: "tray.fill",
            message:
              "No hay productos locales. Sincronice los productos para poder consultarlos sin conexión."
          )
        } else {
          EmptyStateView(
            systemImage: "magnifyingglass",
            message: "No se encontraron productos para \"\(viewModel.searchText)\"."
          )
        }
        Spacer()
      } else {
        ScrollView {
          LazyVStack(spacing: 12) {
            ForEach(viewModel.products) { product in
              ProductRow(product: product, isPresented: $isPresented)
                .environmentObject(settings)
            }
          }
          .padding(.horizontal)
          .padding(.vertical, 8)
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .onAppear(perform: viewModel.onAppear)
  }
}

private struct ProductRow: View {
  let product: Product
  @EnvironmentObject var settings: SettingsManager
  @Binding var isPresented: Bool
  @State private var isPressed = false

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Header del producto con gradiente
      HStack(alignment: .top, spacing: 12) {
        // Ícono del producto
        ZStack {
          RoundedRectangle(cornerRadius: 12)
            .fill(
              LinearGradient(
                colors: [Color.accentColor.opacity(0.1), Color.accentColor.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
          Image(systemName: "cube.box.fill")
            .font(.title2)
            .foregroundStyle(
              LinearGradient(
                colors: [.accentColor, Color.accentColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
        }
        .frame(width: 56, height: 56)

        VStack(alignment: .leading, spacing: 6) {
          Text(product.desproducto ?? "Sin descripción")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.primary)
            .lineLimit(2)

          HStack(spacing: 6) {
            Image(systemName: "building.2.fill")
              .font(.caption2)
            Text(product.nombre_departamento ?? "N/A")
              .font(.subheadline)
          }
          .foregroundColor(.secondary)
        }

        Spacer(minLength: 0)
      }
      .padding(16)

      Divider()
        .padding(.horizontal, 16)

      // Información de códigos
      HStack(spacing: 0) {
        InfoChip(
          icon: "number.circle.fill",
          label: "Código",
          value: product.codproducto ?? "S/C",
          color: .accentColor
        )

        Divider()
          .frame(height: 40)

        InfoChip(
          icon: "doc.text.fill",
          label: "Referencia",
          value: product.referencia ?? "N/A",
          color: .accentColor
        )

        Divider()
          .frame(height: 40)

        InfoChip(
          icon: "shippingbox.fill",
          label: "Bodega",
          value: product.codbodega ?? "N/A",
          color: .accentColor
        )
      }
      .padding(.vertical, 12)
      .padding(.horizontal, 16)

      if let barcode = product.codigobarra, !barcode.isEmpty {
        Divider()
          .padding(.horizontal, 16)

        HStack(spacing: 8) {
          Image(systemName: "barcode.viewfinder")
            .foregroundColor(.accentColor)
          Text(barcode)
            .font(.system(.subheadline, design: .monospaced))
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.05))
      }

      Divider()
        .padding(.horizontal, 16)

      // Sección de precios y existencias
      HStack(spacing: 0) {
        // Existencia
        VStack(spacing: 4) {
          HStack(spacing: 4) {
            Image(systemName: "chart.bar.fill")
              .font(.caption2)
            Text("Existencia")
              .font(.caption)
          }
          .foregroundColor(.secondary)

          Text("\(product.existencias ?? 0, specifier: "%.2f")")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(
              (product.existencias ?? 0) > 0
                ? LinearGradient(
                  colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                : LinearGradient(
                  colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
            )
        }
        .frame(maxWidth: .infinity)

        Divider()
          .frame(height: 50)

        // Último Costo
        VStack(spacing: 4) {
          HStack(spacing: 4) {
            Image(systemName: "arrow.down.circle.fill")
              .font(.caption2)
            Text("Últ. Costo")
              .font(.caption)
          }
          .foregroundColor(.secondary)

          Text("$\(product.ultcosto ?? 0, specifier: "%.2f")")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)

        Divider()
          .frame(height: 50)

        // Precio de Venta
        VStack(spacing: 4) {
          HStack(spacing: 4) {
            Image(systemName: "tag.fill")
              .font(.caption2)
            Text("P. Venta")
              .font(.caption)
          }
          .foregroundColor(.secondary)

          Text("$\(product.preciodeventa ?? 0, specifier: "%.2f")")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(
              LinearGradient(
                colors: [.accentColor, Color.accentColor.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
        }
        .frame(maxWidth: .infinity)
      }
      .padding(.vertical, 16)
      .padding(.horizontal, 16)

      // Footer con indicador de doble tap
      HStack {
        Image(systemName: "hand.tap.fill")
          .font(.caption2)
        Text("Toca dos veces para seleccionar")
          .font(.caption2)
        Spacer()
      }
      .foregroundColor(.secondary)
      .padding(.horizontal, 16)
      .padding(.bottom, 12)
      .padding(.top, 4)
      .background(Color(.systemGray6).opacity(0.5))
    }
    .background(Color(.systemBackground))
    .cornerRadius(16)
    .shadow(
      color: Color.black.opacity(isPressed ? 0.15 : 0.08), radius: isPressed ? 12 : 8, x: 0,
      y: isPressed ? 6 : 4
    )
    .scaleEffect(isPressed ? 0.98 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    .onTapGesture(count: 2) {
      print(
        "OfflineProductsView: Double-tapped on product with code: \(product.codproducto ?? "N/A")")

      // Haptic feedback
      let impactMed = UIImpactFeedbackGenerator(style: .medium)
      impactMed.impactOccurred()

      withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
        isPressed = true
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
          isPressed = false
        }
      }

      settings.selectedProductCodeForSearch = product.codproducto
      isPresented = false
    }
  }
}

// Componente reutilizable para los chips de información
private struct InfoChip: View {
  let icon: String
  let label: String
  let value: String
  let color: Color

  var body: some View {
    VStack(spacing: 6) {
      HStack(spacing: 4) {
        Image(systemName: icon)
          .font(.caption2)
        Text(label)
          .font(.caption2)
      }
      .foregroundColor(.secondary)

      Text(value)
        .font(.system(size: 13, weight: .semibold))
        .foregroundColor(color)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  NavigationView {
    OfflineProductsView(isPresented: .constant(true))
      .environmentObject(SettingsManager.shared)
  }
}
