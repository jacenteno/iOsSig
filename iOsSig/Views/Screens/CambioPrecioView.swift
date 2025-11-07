import SwiftUI

struct CambioPrecioView: View {
    let codigo: String
    @StateObject private var viewModel = CambioPrecioViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var productViewModel: ProductViewModel
    
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            // Fondo con gradiente sutil
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.accentColor.opacity(0.03)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card - Información del Producto
                    if let product = viewModel.product {
                        VStack(spacing: 0) {
                            // Ícono del producto
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.accentColor.opacity(0.1), Color.accentColor.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.accentColor, .accentColor.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .padding(.top, 24)
                            .padding(.bottom, 16)
                            
                            // Nombre del producto
                            Text(product.desproducto ?? "Sin nombre")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 8)
                            
                            // Código del producto
                            HStack(spacing: 6) {
                                Image(systemName: "number.circle.fill")
                                    .font(.caption)
                                Text("Código: \(codigo)")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                            
                            Divider()
                            
                            // Precio actual destacado
                            VStack(spacing: 8) {
                                Text("Precio Actual")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .tracking(1)
                                
                                Text("$\(product.preciodeventa ?? 0.0, specifier: "%.2f")")
                                    .font(.system(size: 42, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.red, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .padding(.vertical, 24)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.05))
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    } else {
                        // Estado de carga
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Cargando producto...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    
                    // Card de Nuevo Precio
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.accentColor)
                            Text("Nuevo Precio")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        // Campo de texto personalizado
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Text("$")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.accentColor)
                                
                                TextField("0.00", text: $viewModel.newPriceString)
                                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .focused($isTextFieldFocused)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.accentColor.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                isTextFieldFocused ? Color.accentColor : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            )
                            
                            // Comparación de precios
                            if let currentPrice = viewModel.product?.preciodeventa,
                               let newPrice = Double(viewModel.newPriceString.replacingOccurrences(of: ",", with: ".")),
                               newPrice > 0 {
                                let difference = newPrice - currentPrice
                                let percentage = (difference / currentPrice) * 100
                                
                                HStack(spacing: 8) {
                                    Image(systemName: difference >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                        .foregroundColor(difference >= 0 ? .green : .red)
                                    
                                    Text(difference >= 0 ? "+" : "")
                                    + Text("$\(abs(difference), specifier: "%.2f")")
                                    + Text(" (\(abs(percentage), specifier: "%.1f")%)")
                                    
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(difference >= 0 ? .green : .red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill((difference >= 0 ? Color.green : Color.red).opacity(0.1))
                                )
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // Botón de acción
                    Button(action: {
                        isTextFieldFocused = false
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        
                        Task {
                            await viewModel.updatePrice(codigo: codigo)
                        }
                    }) {
                        HStack(spacing: 12) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Procesando...")
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                Text("Cambiar Precio")
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Group {
                                if viewModel.isLoading || viewModel.newPriceString.isEmpty {
                                    LinearGradient(
                                        colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.4)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                } else {
                                    LinearGradient(
                                        colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                            }
                        )
                        .cornerRadius(16)
                        .shadow(
                            color: viewModel.isLoading || viewModel.newPriceString.isEmpty
                                ? Color.clear
                                : Color.accentColor.opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    }
                    .disabled(viewModel.isLoading || viewModel.newPriceString.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                    
                    // Info adicional
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.accentColor)
                        Text("El cambio se aplicará de inmediato")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Cambio de Precio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Listo") {
                        isTextFieldFocused = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchProduct(codigo: codigo)
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertMessage.starts(with: "Precio actualizado") ? "✓ Éxito" : "⚠️ Atención"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if viewModel.alertMessage.starts(with: "Precio actualizado") {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        productViewModel.fetchProducts()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}

#Preview {
    NavigationView {
        CambioPrecioView(codigo: "12345")
            .environmentObject(ProductViewModel())
    }
}
