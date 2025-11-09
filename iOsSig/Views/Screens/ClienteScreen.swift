import SwiftUI

struct ClienteScreen: View {
    @StateObject private var viewModel = ClienteViewModel()
    @EnvironmentObject var settings: SettingsManager

    @State private var valor: String = ""
    @State private var showConfetti: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // FONDO GRADIENTE DINÁMICO
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGroupedBackground),
                        Color(hex: settings.accentColor)?.opacity(0.05) ?? Color.accentColor.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // BARRA DE BÚSQUEDA MODERNA
                    ModernSearchBar(text: $valor) {
                        Task {
                            await viewModel.fetchCliente(valor: valor.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }

                    ScrollView {
                        VStack(spacing: 24) {
                            // ESTADO VACÍO MODERNO
                            if viewModel.clienteResponse == nil && viewModel.error == nil && viewModel.successMessage == nil {
                                EmptyClienteStateView()
                                    .padding(.top, 60)
                            }

                            // DETALLES DEL CLIENTE
                            if viewModel.clienteResponse != nil {
                                ClienteDetailCardView(viewModel: viewModel)
                            }

                            // PROMOCIONES
                            if let promotions = viewModel.clienteResponse?.activePromotions, !promotions.isEmpty {
                                PromocionesSectionView(promotions: promotions, usedPromotions: viewModel.usedPromotions, viewModel: viewModel, settings: settings)
                            }
                        }
                    }
                }
                .overlay(
                    showConfetti ? ConfettiView().allowsHitTesting(false) : nil
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: valor) { newValue in
                let filteredValue = newValue.filter { "0123456789-".contains($0) }
                if filteredValue != newValue {
                    valor = filteredValue
                }
                if filteredValue.isEmpty {
                    viewModel.clearCliente()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil), actions: {
                Button("Aceptar") { viewModel.clearError() }
            }, message: {
                Text(viewModel.error ?? "Ocurrió un error inesperado.")
            })
            .alert("¡Éxito!", isPresented: .constant(viewModel.successMessage != nil), actions: {
                Button("Aceptar") { viewModel.clearSuccessMessage() }
            }, message: {
                Text(viewModel.successMessage ?? "")
            })
            .sheet(item: $viewModel.coupon) { couponData in
                CouponDialogModernView(
                    coupon: couponData,
                    accentColor: Color(hex: settings.accentColor) ?? .accentColor,
                    onDismiss: { viewModel.clearCoupon() },
                    onDownloadQr: {
                        print("Descargando QR: \(couponData.qrCode)")
                        viewModel.clearCoupon()
                    }
                )
            }
            .onReceive(viewModel.$clienteResponse) { response in
                if (response?.cliente.balancePts ?? 0) > 0 {
                    showConfetti = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        showConfetti = false
                    }
                }
            }
        }
    }
}

// MARK: - Componentes UI Modernos

struct ModernSearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.secondary)

            TextField("Buscar por código o RUT", text: $text)
                .font(.system(size: 17, weight: .medium))
                .onSubmit(onSearch)
                .submitLabel(.search)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

struct EmptyClienteStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.text.rectangle.fill")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolRenderingMode(.hierarchical)

            Text("Busca un cliente")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("Ingresa su código o RUT para ver detalles y promociones.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

struct ClienteDetailCardView: View {
    @ObservedObject var viewModel: ClienteViewModel
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        if let cli = viewModel.clienteResponse?.cliente {
            VStack(alignment: .leading, spacing: 20) {
                // HEADER
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: settings.accentColor) ?? .accentColor, Color(hex: settings.accentColor)?.opacity(0.6) ?? .accentColor.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)

                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .symbolRenderingMode(.hierarchical)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(cli.nombre.trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(2)

                        Text("Balance: \(String(format: "%.0f", cli.balancePts)) Pts")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: settings.accentColor) ?? .accentColor)
                    }

                    Spacer()
                }

                // SECCIONES
                ModernSectionView(title: "Información de Contacto", icon: "phone.circle.fill") {
                    ModernLabeledContent(label: "Teléfono 1", value: cli.telefono1.trimmingCharacters(in: .whitespacesAndNewlines))
                    ModernLabeledContent(label: "Teléfono 2", value: cli.telefono2.trimmingCharacters(in: .whitespacesAndNewlines))
                    ModernLabeledContent(label: "Email", value: cli.email.trimmingCharacters(in: .whitespacesAndNewlines))
                }

                ModernSectionView(title: "Detalles de Cuenta", icon: "person.badge.key.fill") {
                    ModernLabeledContent(label: "Código", value: String(cli.codcliente))
                    ModernLabeledContent(label: "Cédula", value: cli.rut?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "N/A")
                    ModernLabeledContent(label: "Jubilado", value: cli.jubilado == 1 ? "Sí" : "No")
                    ModernLabeledContent(label: "Activo", value: cli.inactivoprgfidelidad == 0 ? "Sí" : "No")
                    ModernLabeledContent(label: "Género", value: cli.genero)
                    ModernLabeledContent(label: "Cumpleaños", value: viewModel.formattedNacimiento)
                }

                ModernSectionView(title: "Resumen del Programa", icon: "star.circle.fill") {
                    ModernLabeledContent(label: "Puntos Acumulados", value: String(format: "%.0f", cli.suma))
                    ModernLabeledContent(label: "Puntos Canjeados", value: String(format: "%.0f", cli.resta))
                    ModernLabeledContent(label: "Total Facturas", value: String(format: "%.0f", cli.totalFacturas))
                    ModernLabeledContent(label: "Consumo Total", value: String(format: "$%.2f", cli.consumido))
                }

                // BOTÓN FINALIZAR
                Button(action: {
                    viewModel.clearCliente()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Finalizar Consulta")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.red, .red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .red.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .padding(.top, 8)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
    }
}

struct ModernSectionView<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.accentColor)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }

            VStack(spacing: 10) {
                content()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

struct ModernLabeledContent: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

struct PromocionesSectionView: View {
    let promotions: [Promotion]
    let usedPromotions: [Int]
    let viewModel: ClienteViewModel
    let settings: SettingsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                Image(systemName: "gift.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.accentColor)

                Text("Premios CityPuntos")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)

            LazyVStack(spacing: 16) {
                ForEach(promotions, id: \.id) { promotion in
                    PromotionModernCardView(
                        promotion: promotion,
                        isUsed: usedPromotions.contains(promotion.id),
                        accentColor: Color(hex: settings.accentColor) ?? .accentColor
                    ) {
                        Task {
                            if let rutNumerico = viewModel.clienteResponse?.cliente.rutnumerico {
                                await viewModel.generateCoupon(promo: promotion, rutNumerico: rutNumerico)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PromotionModernCardView: View {
    let promotion: Promotion
    let isUsed: Bool
    let accentColor: Color
    let onGenerateCoupon: () -> Void

    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: isUsed ? "checkmark.circle.fill" : "gift.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isUsed ? .green : accentColor)
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(promotion.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        StatusTagModern(isActive: promotion.isCurrentlyActive, isUsed: isUsed)

                        if promotion.isCurrentlyActive && !isUsed {
                            Text("Disponible")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.green)
                        }
                    }
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                ModernPromoRow(icon: "percent", label: "Descuento", value: "\(promotion.discountValue)%")
                ModernPromoRow(icon: "calendar", label: "Válido", value: promotion.specificDate ?? "No especificada")
                ModernPromoRow(icon: "clock", label: "Horario", value: "\(promotion.specificStartTime ?? "N/A") - \(promotion.specificEndTime ?? "N/A")")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.secondary)

            if promotion.isCurrentlyActive && !isUsed {
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onGenerateCoupon()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Generar Cupón")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .scaleEffect(isPressed ? 0.96 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                .onTapGesture {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }
            } else if isUsed {
                Label("Cupón ya otorgado", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.green.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

struct ModernPromoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 16)

            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

struct StatusTagModern: View {
    let isActive: Bool
    let isUsed: Bool

    var body: some View {
        if isUsed {
            Text("Usada")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.green)
                .clipShape(Capsule())
        } else if isActive {
            Text("Activa")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.accentColor)
                .clipShape(Capsule())
        } else {
            Text("Inactiva")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.gray)
                .clipShape(Capsule())
        }
    }
}

struct CouponDialogModernView: View {
    let coupon: Coupon
    let accentColor: Color
    let onDismiss: () -> Void
    let onDownloadQr: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // HEADER
            VStack(spacing: 8) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(accentColor)
                    .symbolRenderingMode(.hierarchical)

                Text("¡Cupón Generado!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }

            // QR
            if let qrCodeURL = URL(string: coupon.qrCode) {
                AsyncImage(url: qrCodeURL) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            } else {
                Image(systemName: "qrcode")
                    .font(.system(size: 100))
                    .foregroundColor(.secondary)
            }

            // INFO
            VStack(spacing: 6) {
                Text("Código: \(coupon.codigo)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)

                Text("Válido hasta: \(coupon.validoHasta)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }

            // BOTONES
            VStack(spacing: 12) {
                Button(action: onDownloadQr) {
                    Label("Descargar QR", systemImage: "square.and.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(accentColor)

                Button("Finalizar", action: onDismiss)
                    .font(.system(size: 16, weight: .medium))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(30)
        .presentationDetents([.medium])
    }
}
