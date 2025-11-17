import SwiftUI

struct AccesoScreen: View {
  @EnvironmentObject var settings: SettingsManager
  @Binding var isUnlocked: Bool
  @Binding var showLockScreen: Bool

  @State private var enteredPassword = ""
  @State private var passwordError = false
  @State private var attempts = 0
  @State private var isPressed = false
  @State private var showShake = false

  let validPasswords: Set<String> = ["999999", "admin", "9999"]
  let maxAttempts = 3

  var body: some View {
    ZStack {
      // FONDO GRADIENTE DINÁMICO
      LinearGradient(
        gradient: Gradient(colors: [
          Color(.systemGroupedBackground),
          Color(hex: settings.accentColor)?.opacity(0.08) ?? Color.accentColor.opacity(0.08),
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(spacing: 24) {
        // HEADER ANIMADO
        headerSection

        // TARJETA PRINCIPAL
        mainCard
          .offset(x: showShake ? -10 : 0)
          .animation(.interpolatingSpring(stiffness: 500, damping: 5), value: showShake)

        Spacer()
      }
      .padding(.horizontal, 24)
      .padding(.top, 40)
    }
  }

  private var headerSection: some View {
    VStack(spacing: 12) {
      ZStack {
        Circle()
          .fill(
            LinearGradient(
              colors: [
                Color(hex: settings.accentColor) ?? .accentColor,
                Color(hex: settings.accentColor)?.opacity(0.6) ?? .accentColor.opacity(0.6),
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 80, height: 80)
          .shadow(
            color: Color(hex: settings.accentColor)?.opacity(0.3) ?? .accentColor.opacity(0.3),
            radius: 10, x: 0, y: 5)

        Image(systemName: "lock.shield.fill")
          .font(.system(size: 40, weight: .bold))
          .foregroundColor(.white)
          .symbolRenderingMode(.hierarchical)
          .symbolEffect(.pulse, options: .repeating)
      }

      Text("Acceso Restringido")
        .font(.system(size: 28, weight: .bold, design: .rounded))
        .foregroundColor(.primary)

      Text("Ingresa la clave para continuar")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.top, 20)
  }

  private var mainCard: some View {
    VStack(spacing: 20) {
      // CAMPO DE CONTRASEÑA MODERNO
      passwordField

      // MENSAJE DE ERROR ANIMADO
      if passwordError {
        errorMessage
          .transition(.scale.combined(with: .opacity))
      }

      // BOTÓN PRINCIPAL
      unlockButton

      // BOTÓN SECUNDARIO
      cancelButton
    }
    .padding(24)
    .background(
      RoundedRectangle(cornerRadius: 24)
        .fill(Color(.systemBackground))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
  }

  private var passwordField: some View {
    HStack(spacing: 12) {
      Image(systemName: "key.fill")
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(Color(hex: settings.accentColor) ?? .accentColor)

      SecureField("Clave de acceso", text: $enteredPassword)
        .font(.system(size: 18, weight: .medium))
        .disabled(attempts >= maxAttempts)
        .onSubmit {
          attemptUnlock()
        }
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color(.secondarySystemBackground))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(
          passwordError
            ? Color.red.opacity(0.6)
            : Color(hex: settings.accentColor)?.opacity(0.3) ?? Color.accentColor.opacity(0.3),
          lineWidth: 2
        )
    )
    .animation(.easeInOut(duration: 0.2), value: passwordError)
  }

  private var errorMessage: some View {
    HStack(spacing: 8) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 14, weight: .bold))
        .foregroundColor(.red)

      if attempts >= maxAttempts {
        Text("Demasiados intentos fallidos")
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(.red)
      } else {
        Text("Clave incorrecta. \(maxAttempts - attempts) intentos restantes.")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.red)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.red.opacity(0.1))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.red.opacity(0.2), lineWidth: 1)
    )
  }

  private var unlockButton: some View {
    Button(action: attemptUnlock) {
      HStack(spacing: 8) {
        Image(systemName: "lock.open.fill")
          .font(.system(size: 18, weight: .semibold))

        Text("Desbloquear")
          .font(.system(size: 18, weight: .semibold))
      }
      .foregroundColor(.white)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(
        LinearGradient(
          colors: [
            Color(hex: settings.accentColor) ?? .accentColor,
            Color(hex: settings.accentColor)?.opacity(0.8) ?? .accentColor.opacity(0.8),
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .cornerRadius(16)
      .shadow(
        color: (Color(hex: settings.accentColor) ?? .accentColor).opacity(0.4), radius: 8, x: 0,
        y: 4
      )
      .scaleEffect(isPressed ? 0.96 : 1.0)
      .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
    .disabled(attempts >= maxAttempts)
    .opacity(attempts >= maxAttempts ? 0.6 : 1.0)
  }

  private var cancelButton: some View {
    Button(action: {
      let impactFeedback = UIImpactFeedbackGenerator(style: .light)
      impactFeedback.impactOccurred()
      showLockScreen = false
    }) {
      Text("Cancelar")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(Color(hex: settings.accentColor) ?? .accentColor)
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: settings.accentColor)?.opacity(0.1) ?? Color.accentColor.opacity(0.1))
        )
    }
  }

  private func attemptUnlock() {
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    impactFeedback.impactOccurred()

    if validPasswords.contains(enteredPassword) {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
        isUnlocked = true
        showLockScreen = false
      }
    } else {
      withAnimation {
        passwordError = true
        showShake = true
        enteredPassword = ""
        attempts += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          showShake = false
        }
      }
    }
  }
}

struct AccesoScreen_Previews: PreviewProvider {
  static var previews: some View {
    AccesoScreen(isUnlocked: .constant(false), showLockScreen: .constant(true))
      .environmentObject(SettingsManager.shared)
  }
}
