import SwiftUI

struct CambioPrecioView: View {
    let codigo: String

    var body: some View {
        Text("Pantalla de Cambio de Precio para el producto: \(codigo)")
            .font(.largeTitle)
            .navigationTitle("Cambio de Precio")
    }
}