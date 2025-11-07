
import SwiftUI

struct EtiquetaScreen: View {
    let product: Product
    @StateObject private var viewModel = EtiquetaViewModel()
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isTextFieldFocused: Bool

    private var isButtonDisabled: Bool {
        let cantidadInt = Int(viewModel.cantidad) ?? 0
        return cantidadInt <= 0
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

                        // Card de Cantidad
                        quantityInputCard

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Imprimir Etiquetas")
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
                            isTextFieldFocused = false
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                actionButton
                    .padding()
                    .background(.thinMaterial)
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.alertMessage.starts(with: "Se han enviado") ? "✓ Éxito" : "⚠️ Error"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if viewModel.alertMessage.starts(with: "Se han enviado") {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
            .onAppear {
                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
        }
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

                Image(systemName: "printer.fill")
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

    private var quantityInputCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.accentColor)
                Text("Cantidad de Etiquetas")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 12) {
                TextField("1", text: $viewModel.cantidad)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .keyboardType(.numberPad)
                    .focused($isTextFieldFocused)
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
                                isTextFieldFocused ? Color.accentColor : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    private var actionButton: some View {
        Button(action: {
            viewModel.printLabels(product: product)
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
        }) {
            HStack(spacing: 12) {
                Image(systemName: "printer.fill")
                    .font(.title3)
                Text("Imprimir")
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
                color: isButtonDisabled ? .clear : .accentColor.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(isButtonDisabled)
    }
}

#Preview {
    EtiquetaScreen(product: Product.sample)
}
