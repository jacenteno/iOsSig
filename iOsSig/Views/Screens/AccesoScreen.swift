import SwiftUI

struct AccesoScreen: View {
    @EnvironmentObject var settings: SettingsManager
    @Binding var isUnlocked: Bool
    @Binding var showLockScreen: Bool
    
    @State private var enteredPassword = ""
    @State private var passwordError = false
    @State private var attempts = 0
    
    let validPasswords: Set<String> = ["999999", "admin", "9999"]
    let maxAttempts = 3
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Acceso Restringido")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Por favor, ingrese la clave para continuar.")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            SecureField("Clave", text: $enteredPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.default)
                .disabled(attempts >= maxAttempts)
            
            if passwordError {
                Text("Clave incorrecta. Le quedan \(maxAttempts - attempts) intentos.")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if attempts >= maxAttempts {
                Text("Ha excedido el número de intentos.")
                    .foregroundColor(.red)
                    .font(.headline)
            }
            
            Button(action: {
                if validPasswords.contains(enteredPassword) {
                    isUnlocked = true
                    showLockScreen = false
                } else {
                    passwordError = true
                    enteredPassword = ""
                    attempts += 1
                }
            }) {
                Text("Desbloquear")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: settings.accentColor) ?? .accentColor)
                    .cornerRadius(10)
            }
            .disabled(attempts >= maxAttempts)
            
            Button("Cancelar") {
                showLockScreen = false
            }
            .padding()
            .foregroundColor(Color(hex: settings.accentColor) ?? .accentColor)
        }
        .padding()
    }
}

struct AccesoScreen_Previews: PreviewProvider {
    static var previews: some View {
        AccesoScreen(isUnlocked: .constant(false), showLockScreen: .constant(true))
            .environmentObject(SettingsManager.shared)
    }
}
