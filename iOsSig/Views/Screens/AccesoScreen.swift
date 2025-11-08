import SwiftUI

struct AccesoScreen: View {
    @Binding var isUnlocked: Bool
    @Binding var showLockScreen: Bool
    
    @State private var enteredPassword = ""
    @State private var passwordError = false
    
    let correctPassword = "999999"
    
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
                .keyboardType(.numberPad)
            
            if passwordError {
                Text("Clave incorrecta. Por favor, intente de nuevo.")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                if enteredPassword == correctPassword {
                    isUnlocked = true
                    showLockScreen = false
                } else {
                    passwordError = true
                    enteredPassword = ""
                }
            }) {
                Text("Desbloquear")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            
            Button("Cancelar") {
                showLockScreen = false
            }
            .padding()
        }
        .padding()
    }
}

struct AccesoScreen_Previews: PreviewProvider {
    static var previews: some View {
        AccesoScreen(isUnlocked: .constant(false), showLockScreen: .constant(true))
    }
}
