
import SwiftUI

struct AddProductToOrderView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.presentationMode) var presentationMode

    @State private var unidades: String = ""
    @State private var cajas: String = "1"
    @FocusState private var isUnidadesFieldFocused: Bool
    @FocusState private var isCajasFieldFocused: Bool

    private var isButtonDisabled: Bool {
        let unidadesInt = Int(unidades) ?? 0
        let cajasInt = Int(cajas) ?? 0
        return unidadesInt <= 0 && cajasInt <= 0
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color.accentColor.opacity(0.03)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header Card - Información del Producto
                        productInfoCard
                            .padding(.top, 20)

                        // Card de Cantidades
                        quantitiesInputCard

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Agregar al Pedido")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Listo") {
                            if isUnidadesFieldFocused {
                                isUnidadesFieldFocused = false
                            }
                            if isCajasFieldFocused {
                                isCajasFieldFocused = false
                            }
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Botón de acción fijo en la parte inferior
                actionButton
                    .padding()
                    .background(.thinMaterial)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isCajasFieldFocused = true
                }
            }
        }
        .accentColor(Color(hex: settings.accentColor) ?? .accentColor)
    }

    // MARK: - Subviews

    private var productInfoCard: some View {
        VStack(spacing: 0) {
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

                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, Color.accentColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 24)
            .padding(.bottom, 16)

            Text(product.desproducto ?? "Sin nombre")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            HStack(spacing: 6) {
                Image(systemName: "number.circle.fill")
                    .font(.caption)
                 Text("Código: \(product.codproducto ?? "N/A")")
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    private var quantitiesInputCard: some View {
        VStack(spacing: 20) {
            // Campo de Cajas
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "archivebox.circle.fill")
                        .foregroundColor(.accentColor)
                    Text("Cantidad en Cajas")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                HStack(spacing: 12) {
                    TextField("0", text: $cajas)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .keyboardType(.numberPad)
                        .focused($isCajasFieldFocused)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accentColor.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isCajasFieldFocused ? Color.accentColor : Color.clear,
                                    lineWidth: 2
                                )
                        )
                )
            }

            // Campo de Unidades
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "shippingbox.circle.fill")
                        .foregroundColor(.accentColor)
                    Text("Cantidad en Unidades")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                HStack(spacing: 12) {
                    TextField("0", text: $unidades)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .keyboardType(.numberPad)
                        .focused($isUnidadesFieldFocused)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accentColor.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isUnidadesFieldFocused ? Color.accentColor : Color.clear,
                                    lineWidth: 2
                                )
                        )
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    private var actionButton: some View {
        Button(action: {
            let unidadesInt = Int(unidades) ?? 0
            let cajasInt = Int(cajas) ?? 0
            
            cartManager.addItem(product: product, unidades: unidadesInt, cajas: cajasInt)
            
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
            
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Agregar al Pedido")
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if isButtonDisabled {
                        LinearGradient(
                            colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.5)],
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
                color: isButtonDisabled ? .clear : Color.accentColor.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(isButtonDisabled)
    }
}

#Preview {
    AddProductToOrderView(product: Product.sample)
        .environmentObject(CartManager())
}
