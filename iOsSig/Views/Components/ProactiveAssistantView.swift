import SwiftUI

/// La vista principal para el "Asistente Proactivo".
struct ProactiveAssistantView: View {

  @StateObject private var viewModel = ProactiveAssistantViewModel()

  var body: some View {
    Group {
      if viewModel.isLoading {
        ProgressView("Analizando inventario...")
      } else if viewModel.inventoryAlerts.isEmpty {
        VStack {
          Image(systemName: "checkmark.seal.fill")
            .font(.system(size: 60))
            .foregroundColor(.green)
          Text("¡Todo en orden!")
            .font(.title)
            .fontWeight(.bold)
            .padding(.top, 8)
          Text("No se encontraron productos con riesgo de quiebre de stock.")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding()
        }
      } else {
        List {
          ForEach(viewModel.inventoryAlerts) { alert in
            InventoryAlertCardView(alert: alert)
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
              .padding(.vertical, 8)
          }
        }
        .listStyle(.plain)
      }
    }
    .searchable(text: $viewModel.searchQuery, prompt: "Buscar por nombre, código o referencia...")
    .navigationTitle("Productos Agotados")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          // Acción para recargar los datos
          Task {
            await viewModel.generateAlerts()
          }
        }) {
          Image(systemName: "arrow.clockwise")
        }
      }
    }
    .onAppear {
      // Carga inicial de los datos al aparecer la vista
      Task {
        await viewModel.generateAlerts()
      }
    }
  }

}

#Preview {
  NavigationView {
    ProactiveAssistantView()
  }
}
