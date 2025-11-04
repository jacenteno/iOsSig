import SwiftUI

struct ClienteScreen: View {
    @StateObject private var viewModel = ClienteViewModel()
    @Environment(\.presentationMode) var presentationMode // For navigating back
    @EnvironmentObject var settings: SettingsManager // Assuming SettingsManager is an EnvironmentObject

    @State private var valor: String = ""
    @State private var showConfetti: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea() // Background color

                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.clienteResponse == nil && viewModel.error == nil && viewModel.successMessage == nil {
                            VStack(spacing: 10) {
                                Image(systemName: "person.text.rectangle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                                Text("Busca un cliente por su código o RUT.")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                Text("Usa la barra de búsqueda de arriba para empezar.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 50)
                        }

                        if viewModel.clienteResponse != nil {
                            ClienteDetailView(viewModel: viewModel)
                        }

                        if let promotions = viewModel.clienteResponse?.activePromotions, !promotions.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Premios CityPuntos:")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top, 16)
                                ForEach(promotions, id: \.id) { promotion in
                                    PromotionCardView(promotion: promotion, isUsed: viewModel.usedPromotions.contains(promotion.id)) {
                                        Task {
                                            if let rutNumerico = viewModel.clienteResponse?.cliente.rutnumerico {
                                                await viewModel.generateCoupon(promo: promotion, rutNumerico: rutNumerico)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Consulta de Cliente")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $valor, placement: .navigationBarDrawer(displayMode: .always)) {
                    // Optional: Add suggestions here if needed
                }
                .onSubmit(of: .search) {
                    Task {
                        await viewModel.fetchCliente(valor: valor.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
                .onChange(of: valor) { newValue in
                    let filteredValue = newValue.filter { $0.isNumber || $0 == "-" }
                    if filteredValue != newValue {
                        valor = filteredValue
                    }
                    if filteredValue.isEmpty {
                        viewModel.clearCliente()
                    }
                }

                // Error and Success Alerts
                .alert("Error", isPresented: Binding<Bool>(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.clearError() } }
                )) {
                    Button("Aceptar") { viewModel.clearError() }
                } message: {
                    Text(viewModel.error ?? "")
                }
                .alert("¡Éxito!", isPresented: Binding<Bool>(
                    get: { viewModel.successMessage != nil },
                    set: { if !$0 { viewModel.clearSuccessMessage() } }
                )) {
                    Button("Aceptar") { viewModel.clearSuccessMessage() }
                } message: {
                    Text(viewModel.successMessage ?? "")
                }

                // Coupon Dialog
                .sheet(item: $viewModel.coupon) { couponData in
                    CouponDialogView(coupon: couponData) { // Pass couponData directly
                        viewModel.clearCoupon()
                    } onDownloadQr: {
                        print("Descargando QR: \(couponData.qrCode)")
                        viewModel.clearCoupon()
                    }
                }

                // Confetti effect (simplified)
                if showConfetti {
                    ConfettiView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showConfetti = false
                            }
                        }
                }
            }
        }
        .onReceive(viewModel.$clienteResponse) { response in
            if response?.cliente.balancePts ?? 0 > 0 { // Corrected to use balancePts
                showConfetti = true
            }
        }
    }
}

struct ClienteDetailView: View {
    @ObservedObject var viewModel: ClienteViewModel

    var body: some View {
        if let cli = viewModel.clienteResponse?.cliente {
            CardView1 { // Custom CardView for consistency
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: - Header: Client Name and Balance
                    HStack(alignment: .center) {
                        Image("citypuntos") // Assuming "citypuntos" asset exists
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .padding(.trailing, 8)
                        VStack(alignment: .leading) {
                            Text(cli.nombre.trimmingCharacters(in: .whitespacesAndNewlines))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Balance Puntos: \(String(format: "%.0f", cli.balancePts))")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 8)

                    Divider()

                    // MARK: - Contact Information
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Información de Contacto")
                            .font(.headline)
                            .fontWeight(.bold)
                        InfoRow(label: "Tel. 1", value: cli.telefono1.trimmingCharacters(in: .whitespacesAndNewlines))
                        InfoRow(label: "Tel. 2", value: cli.telefono2.trimmingCharacters(in: .whitespacesAndNewlines))
                        InfoRow(label: "Email", value: cli.email.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    .padding(.vertical, 8)

                    Divider()

                    // MARK: - Account Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detalles de Cuenta")
                            .font(.headline)
                            .fontWeight(.bold)
                        InfoRow(label: "Código", value: String(cli.codcliente))
                        InfoRow(label: "Cédula", value: cli.rut?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No disponible")
                        InfoRow(label: "Jubilado", value: cli.jubilado == 1 ? "Sí" : "No")
                        InfoRow(label: "Activo", value: cli.inactivoprgfidelidad == 0 ? "Sí" : "No")
                        InfoRow(label: "Género", value: cli.genero)
                        InfoRow(label: "Cumpleaños", value: viewModel.formattedNacimiento)
                    }
                    .padding(.vertical, 8)

                    Divider()

                    // MARK: - Loyalty Program Summary
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Resumen Programa de Lealtad")
                            .font(.headline)
                            .fontWeight(.bold)
                        InfoRow(label: "Puntos +", value: String(format: "%.0f", cli.suma))
                        InfoRow(label: "Puntos -", value: String(format: "%.0f", cli.resta))
                        InfoRow(label: "No. Facturas", value: String(format: "%.0f", cli.totalFacturas))
                        InfoRow(label: "Consumido", value: String(format: "%.2f", cli.consumido))
                    }
                    .padding(.vertical, 8)

                    Spacer().frame(height: 16)

                    // MARK: - Action Button
                    Button(action: {
                        viewModel.clearCliente()
                    }) {
                        VStack {
                            Text("Finalizar Consulta")
                                .font(.headline)
                                .fontWeight(.medium)
                            Text("\(Int(cli.balancePts)) Pts.")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .padding(.horizontal)
        }
    }
}


struct PromotionCardView: View {
    let promotion: Promotion
    let isUsed: Bool
    let onGenerateCoupon: () -> Void

    var body: some View {
        CardView1 { // Custom CardView for consistency
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("\(promotion.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                    if promotion.isCurrentlyActive && !isUsed {
                        Text("Activa")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(5)
                    } else if isUsed {
                        Text("Usada")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                    } else {
                        Text("Inactiva")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(5)
                    }
                }
                Text("Descuento: \(promotion.discountValue)%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Válido: \(promotion.specificDate ?? "No especificada")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Horario: \(promotion.specificStartTime ?? "N/A") - \(promotion.specificEndTime ?? "N/A")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if promotion.isCurrentlyActive && !isUsed {
                    Button(action: onGenerateCoupon) {
                        Text("Generar Cupón")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else if isUsed {
                    Text("Cupón ya otorgado")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.gray)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct CouponDialogView: View {
    let coupon: Coupon
    let onDismiss: () -> Void
    let onDownloadQr: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("¡Cupón Generado!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)

            Text("Escanea este QR para canjear tu promoción.")
                .font(.body)
                .multilineTextAlignment(.center)

            if let qrCodeURL = URL(string: coupon.qrCode) {
                AsyncImage(url: qrCodeURL) {
                    image in image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .cornerRadius(10)
                .shadow(radius: 5)
            } else {
                // Fallback if QR code URL is invalid
                Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
            }

            VStack(spacing: 5) {
                Text("Código: \(coupon.codigo)")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Válido hasta: \(coupon.validoHasta)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 15) {
                Button(action: onDownloadQr) {
                    Label("Descargar QR", systemImage: "square.and.arrow.down")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: onDismiss) {
                    Text("Finalizar")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 10)
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding(.horizontal, 20)
    }
}

struct ConfettiView: View {
    @State private var animate: Bool = false

    var body: some View {
        ZStack {
            ForEach(0..<20) { _ in
                Text("🎉")
                    .font(.system(size: .random(in: 10...30)))
                    .offset(x: .random(in: -150...150), y: .random(in: -200...0))
                    .rotationEffect(.degrees(.random(in: 0...360)))
                    .opacity(animate ? 0 : 1)
                    .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: false).delay(.random(in: 0...1)), value: animate)
            }
        }
        .onAppear {
            animate = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .allowsHitTesting(false) // Allow taps to pass through
    }
}

// Extension for optional binding in SwiftUI
extension View {
    //func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
     //   if condition {
    //        return transform(self)
      //  } else {
      //      return self
      //  }
    //}
}
